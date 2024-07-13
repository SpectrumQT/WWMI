Buffer<uint> text : register(t113);

struct TextParameters {
	float4 rect;
	float4 colour;
	float4 background;
	float2 border;
	float h_anchor;
	float v_anchor;
	float h_align;
	float font_scale;
};
StructuredBuffer<TextParameters> params : register(t114);

static float2 cur_pos;
// static float4 resolution;
#define resolution IniParams[0].xy
static float2 char_size;
static int2 meta_pos_start;

// Must be set high enough to counter floating point error in the perspective
// divide. Should be set to at least the font texture width * font_scale.
#define TEXCOORD2_BIAS 4096 /* * font_scale */

// dictated by 1024 / sizeof(gs2ps) / 4
#define CHARS_PER_INVOCATION 64

Texture2D<float> font : register(t100);
Texture1D<float4> IniParams : register(t120);
Texture2D<float4> StereoParams : register(t125);

struct vs2gs {
	uint idx : TEXCOORD0;
};

struct gs2ps {
	float4 pos : SV_Position0;
};

struct cs2gs {
	uint start;
	uint len;
	float2 pos;
};

float2 get_char_dimensions(uint c)
{
	float2 meta_pos;
	float2 dim;

	meta_pos.x = meta_pos_start.x + (c % 16);
	meta_pos.y = meta_pos_start.y + (c / 16 - 2) * 2;

	dim.x = font.Load(int3(meta_pos, 0)) * 255;
	meta_pos.y++;
	dim.y = font.Load(int3(meta_pos, 0)) * 255;

	return dim;
}

#ifdef COMPUTE_SHADER
void get_meta()
{
	// No good in windowed mode:
	//resolution = StereoParams.Load(int3(2, 0, 0));

	// Can't use GetDimensions in a compute shader - it crashes
	// font.GetDimensions(font_width, font_height);

	float font_width = 256, font_height = 96;
	char_size = float2(font_width, font_height) / float2(16, 6);

	meta_pos_start = float2(15 * char_size.x, 5 * char_size.y);
}

RWStructuredBuffer<cs2gs> textpos : register(u0);

[numthreads(1, 1, 1)]
void main()
{
	get_meta();
	float2 char_dim = char_size.xy / resolution.xy * 2 * params[0].font_scale;
	uint pos;
	uint c;
	uint gs = 1;
	uint gs_linestart = 1;
	uint start = 0;
	uint space = -1;
	float space_x = 0;
	float max_x = -1;
	float rect_width = params[0].rect.z - params[0].rect.x;

	cur_pos = 0;
	textpos[gs].start = 0;
	textpos[gs].pos = cur_pos;

	// Can't use GetDimensions in a compute shader - it crashes
	//buf.GetDimensions(strlen);

	// FIXME: Refactor

	for (pos = 0; c = text[pos]; pos++) {
		if (c == ' ') {
			space = pos;
			space_x = cur_pos.x;
		}

		cur_pos.x += get_char_dimensions(c).x / resolution.x * 2 * params[0].font_scale;

		// FIXME: Refactor

		if (c == '\n') {
			textpos[gs].len = pos - start + 1;
			max_x = max(max_x, cur_pos.x);

			if (params[0].h_align == 1) {
				// Center align
				for (uint i = gs_linestart; i <= gs; i++)
					textpos[i].pos.x = (rect_width - cur_pos.x) / 2 + textpos[i].pos.x;
			} else if (params[0].h_align == 2) {
				// Right align
				for (uint i = gs_linestart; i <= gs; i++)
					textpos[i].pos.x = rect_width - cur_pos.x + textpos[i].pos.x;
			}

			gs++;
			gs_linestart = gs;
			start = pos + 1;
			space = -1;
			cur_pos.y -= char_dim.y;
			cur_pos.x = 0;

			textpos[gs].start = start;
			textpos[gs].pos = cur_pos;
			//continue; // XXX: Use of > 1 continue statements triggers a HLSL BUG
		} else if (cur_pos.x >= rect_width) {
			// Long line - wrap text
			if (space != -1) {
				// Wrap at the position of the most recent space
				textpos[gs].len = space - start;
				max_x = max(max_x, space_x);
				start = space + 1;
				pos = space;

				if (params[0].h_align == 1) {
					// Center align
					for (uint i = gs_linestart; i <= gs; i++)
						textpos[i].pos.x = (rect_width - space_x) / 2 + textpos[i].pos.x;
				} else if (params[0].h_align == 2) {
					// Right align
					for (uint i = gs_linestart; i <= gs; i++)
						textpos[i].pos.x = rect_width - space_x + textpos[i].pos.x;
				}

				gs++;
				gs_linestart = gs;
				space = -1;
				cur_pos.y -= char_dim.y;
				cur_pos.x = 0;

				textpos[gs].start = start;
				textpos[gs].pos = cur_pos;
				//continue; // XXX: Use of > 1 continue statements triggers a HLSL BUG
			} else {
				// No space encountered on the line, wrap at this point
				textpos[gs].len = pos - start + 1;
				max_x = max(max_x, cur_pos.x);

				if (params[0].h_align == 1) {
					// Center align
					for (uint i = gs_linestart; i <= gs; i++)
						textpos[i].pos.x = (rect_width - cur_pos.x) / 2 + textpos[i].pos.x;
				} else if (params[0].h_align == 2) {
					// Right align
					for (uint i = gs_linestart; i <= gs; i++)
						textpos[i].pos.x = rect_width - cur_pos.x + textpos[i].pos.x;
				}

				gs++;
				gs_linestart = gs;
				start = pos + 1;
				space = -1;
				cur_pos.y -= char_dim.y;
				cur_pos.x = 0;

				textpos[gs].start = start;
				textpos[gs].pos = cur_pos;
				//continue; // XXX: Use of > 1 continue statements triggers a HLSL BUG
			}
		} else if (pos - start >= CHARS_PER_INVOCATION - 1) {
			// Cut the text every 64 characters for each geometry shader invocation
			textpos[gs].len = pos - start + 1;

			gs++;
			start = pos + 1;

			textpos[gs].start = start;
			textpos[gs].pos = cur_pos;
		}
	}
	textpos[gs].len = pos - start + 1;
	max_x = max(max_x, cur_pos.x);
	if (text[pos-1] != '\n' && text[pos-1] != '\r') {
		cur_pos.y -= char_dim.y;

		if (params[0].h_align == 1) {
			// Center align
			for (uint i = gs_linestart; i <= gs; i++)
				textpos[i].pos.x = (rect_width - cur_pos.x) / 2 + textpos[i].pos.x;
		} else if (params[0].h_align == 2) {
			// Right align
			for (uint i = gs_linestart; i <= gs; i++)
				textpos[i].pos.x = rect_width - cur_pos.x + textpos[i].pos.x;
		}
	}

	// Store the final y position in index 0, which is used to
	// automatically size the background rectangle:
	textpos[0].pos = float2(max_x, cur_pos.y);
}
#endif

void pack_texcoord(inout gs2ps output, float2 texcoord)
{
	// Packs one coordinate of the texcoord into the SV_Position Z to give
	// us room for a few extra characters per geometry shader invocation.
	// Requires 'depth_clip_enable = false' in the d3dx.ini
	output.pos.z = texcoord.x;

	// We can encode the Y texcoord in the SV_Position's W component to
	// maximise the number of characters the geometry shader can produce
	// per invocation. This is a little tricky, since the rasterizer will
	// perform a perspective divide by this value (and "noperspective"
	// doesn't seem to prevent this), so we cannot encode 0 here and must
	// be wary of floating point error that may be introduced by this
	// divide. To counter this problem, we add a fixed bias to the texcoord
	// that will prevent it from being 0 and ensure that floating point
	// error is reduced enough that it will not make a visible difference.
	output.pos.w = texcoord.y + TEXCOORD2_BIAS;
	output.pos.xyz *= output.pos.w;
}

float2 unpack_texcoord(gs2ps input)
{
	return float2(input.pos.z, input.pos.w - TEXCOORD2_BIAS);
}

#ifdef VERTEX_SHADER
void main(uint id : SV_VertexID, out vs2gs output)
{
	output.idx = id;
}
#endif

#ifdef GEOMETRY_SHADER
void get_meta()
{
	float font_width, font_height;

	// No good in windowed mode:
	//resolution = StereoParams.Load(int3(2, 0, 0));

	font.GetDimensions(font_width, font_height);
	char_size = float2(font_width, font_height) / float2(16, 6);

	meta_pos_start = float2(15 * char_size.x, 5 * char_size.y);
}

void emit_char(uint c, inout TriangleStream<gs2ps> ostream)
{
	float2 cdim = get_char_dimensions(c);
	float2 texcoord;

	if (c >= ' ' && c < 0x7f) {
		gs2ps output;
		float2 dim = float2(cdim.x, char_size.y) / resolution.xy * 2 * params[0].font_scale;
		float texture_x_percent = cdim.x / char_size.x;

		texcoord.x = (c % 16) * char_size.x;
		texcoord.y = (c / 16 - 2) * char_size.y;

		output.pos = float4(cur_pos.x        , cur_pos.y - dim.y, 0, 1);
		pack_texcoord(output, texcoord + float2(0, 1) * char_size);
		ostream.Append(output);
		output.pos = float4(cur_pos.x + dim.x, cur_pos.y - dim.y, 0, 1);
		pack_texcoord(output, texcoord + float2(texture_x_percent, 1) * char_size);
		ostream.Append(output);
		output.pos = float4(cur_pos.x        , cur_pos.y        , 0, 1);
		pack_texcoord(output, texcoord + float2(0, 0) * char_size);
		ostream.Append(output);
		output.pos = float4(cur_pos.x + dim.x, cur_pos.y        , 0, 1);
		pack_texcoord(output, texcoord + float2(texture_x_percent, 0) * char_size);
		ostream.Append(output);

		ostream.RestartStrip();
	}

	// Increment current position taking specific character width into account:
	cur_pos.x += cdim.x / resolution.x * 2 * params[0].font_scale;
}

// Using a macro for this because a function requires us to know the size of the buffer
#define EMIT_CHAR_ARRAY(strlen, buf, ostream) \
{ \
	for (uint i = 0; i < strlen; i++) \
		emit_char(buf[i], ostream); \
} \

void print_string_buffer(Buffer<uint> buf, uint start, uint len, inout TriangleStream<gs2ps> ostream)
{
	uint strlen, i;

	//buf.GetDimensions(strlen);

	for (i = start; i < start + len; i++)
		emit_char(buf[i], ostream);
}

void emit_int(int val, inout TriangleStream<gs2ps> ostream)
{
	int digit;

	if (val < 0.0) {
		emit_char('-', ostream);
		val *= -1;
	}

	int e = 0;
	if (val == 0) {
		emit_char('0', ostream);
		return;
	}
	e = log10(val);
	while (e >= 0) {
		digit = uint(val / pow(10, e)) % 10;
		emit_char(digit + 0x30, ostream);
		e--;
	}
}

// isnan() is optimised out by the compiler, which produces a warning that we
// need the /Gis (IEEE Strictness) option to enable it... but that doesn't work
// either... neither does disabling optimisations... Uhh, good job Microsoft?
// Whatever, just implement it ourselves by testing for an exponent of all 1s
// and a non-zero mantissa:
bool workaround_broken_isnan(float x)
{
	return (((asuint(x) & 0x7f800000) == 0x7f800000) && ((asuint(x) & 0x007fffff) != 0));
}

void emit_float(float val, inout TriangleStream<gs2ps> ostream)
{
	int digit;
	int significant = 0;
	int scientific = 0;

	if (workaround_broken_isnan(val)) {
		emit_char('N', ostream);
		emit_char('a', ostream);
		emit_char('N', ostream);
		return;
	}

	if (val < 0.0) {
		emit_char('-', ostream);
		val *= -1;
	}

	if (isinf(val)) {
		emit_char('i', ostream);
		emit_char('n', ostream);
		emit_char('f', ostream);
		return;
	}

	if (val == 0) {
		emit_char('0', ostream);
		return;
	}

	int e = log10(val);
	if (e < 0) {
		if (e < -4) {
			scientific = --e;
			digit = uint(val / pow(10, e)) % 10;
			emit_char(digit + 0x30, ostream);
			significant++;
			e--;
		} else {
			emit_char('0', ostream);
			e = -1;
		}
	} else {
		if (e > 6)
			scientific = e;
		while (e - scientific >= 0) {
			digit = uint(val / pow(10, e)) % 10;
			emit_char(digit + 0x30, ostream);
			if (digit || significant) // Don't count leading 0 as significant, but do count following 0s
				significant++;
			e--;
		}
	}
	if (!scientific && frac(val / pow(10, e + 1)) == 0)
		return;
	emit_char('.', ostream);
	bool emitted = false;
	while (!emitted || (significant < 3 && frac(val / pow(10, e + 1)))) {
		digit = uint(val / pow(10, e)) % 10;
		emit_char(digit + 0x30, ostream);
		significant++;
		e--;
		emitted = true;
	}

	if (scientific) {
		emit_char('e', ostream);
		emit_int(scientific, ostream);
	}
}

void draw_outline_rectangle(float4 r, inout TriangleStream<gs2ps> ostream)
{
	gs2ps output;

	output.pos = float4(r.x - params[0].border.x, r.y + params[0].border.y, -1, 1);
	ostream.Append(output);
	output.pos = float4(r.z + params[0].border.x, r.y + params[0].border.y, -1, 1);
	ostream.Append(output);
	output.pos = float4(r.x - params[0].border.x, r.w - params[0].border.y, -1, 1);
	ostream.Append(output);
	output.pos = float4(r.z + params[0].border.x, r.w - params[0].border.y, -1, 1);
	ostream.Append(output);

	ostream.RestartStrip();
}

StructuredBuffer<cs2gs> textpos : register(t112);

// The max vertex count is dictated by 1024 / sizeof(gs2ps), and the max char count is that / 4
[maxvertexcount(256)]
void main(point vs2gs input[1], inout TriangleStream<gs2ps> ostream)
{
	get_meta();
	uint idx = input[0].idx;
	float2 char_dim = char_size.xy / resolution.xy * 2 * params[0].font_scale;
	float4 r = params[0].rect;

	// Anchor the text & rectangle as requested. This will also resize the
	// background to fit around the text
	float2 center = r.xy + float2(r.z - r.x, r.w - r.y) / 2;
	float2 text_shift = 0;

	if (params[0].h_anchor == 1) { // Anchor Left
		r.xz = float2(r.x, r.x + textpos[0].pos.x);
		if (params[0].h_align)
			text_shift.x = (r.z - params[0].rect.z);
	} else if (params[0].h_anchor == 2) { // Anchor Center
		r.xz = float2(center.x - textpos[0].pos.x/2, center.x + textpos[0].pos.x/2);
		if (params[0].h_align)
			text_shift.x = (r.z - params[0].rect.z) * 2;
	} else if (params[0].h_anchor == 3) { // Anchor Right
		r.xz = float2(r.z - textpos[0].pos.x, r.z);
		if (params[0].h_align)
			text_shift.x = (params[0].rect.x - r.x);
	}

	if (params[0].h_align == 1)
		text_shift.x /= 2;

	if (params[0].v_anchor == 1) // Anchor Top
		r.yw = float2(r.y, r.y + textpos[0].pos.y);
	else if (params[0].v_anchor == 2) // Anchor center
		r.yw = float2(center.y - textpos[0].pos.y/2, center.y + textpos[0].pos.y/2);
	else if (params[0].v_anchor == 3) // Anchor Bottom
		r.yw = float2(r.w - textpos[0].pos.y, r.w);

	if (idx == 0) {
		draw_outline_rectangle(r, ostream);
	} else {
		cur_pos = r.xy + textpos[idx].pos + text_shift;
		print_string_buffer(text, textpos[idx].start, textpos[idx].len, ostream);
	}
}
#endif

#ifdef PIXEL_SHADER
void main(gs2ps input, out float4 o0 : SV_Target0)
{
	float2 texcoord = unpack_texcoord(input);

	if (texcoord.x == -1)
		o0 = params[0].background;
	else
		o0.xyzw = font.Load(int3(texcoord, 0)) * params[0].colour;
}
#endif