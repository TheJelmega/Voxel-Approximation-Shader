float4x4 gWorld : WORLD;
float4x4 gViewProj : VIEWPROJECTION;
float4x4 gWorldViewProj : WORLDVIEWPROJECTION;
float3 gLightDirection = normalize(float3(-.5f, -1.f, 1.5f));

float gVoxelSize = 1.f;
bool gShowMesh = false;
bool gShowBoundingBoxes = false;

struct VS_DATA
{
    float3 pos : POSITION;
    float4 color : COLOR;
    float3 normal : NORMAL;
};
struct GS_DATA
{
    float4 pos : SV_POSITION;
    float4 color : COLOR;
    float3 normal : NORMAL;
};

DepthStencilState EnableDepth
{
    DepthEnable = TRUE;
    DepthWriteMask = ALL;
};

RasterizerState NoCulling
{
    CullMode = NONE;
};

BlendState EnableBlending
{
    BlendEnable[0] = TRUE;
    SrcBlend = SRC_ALPHA;
    DestBlend = INV_SRC_ALPHA;
};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
VS_DATA VS(VS_DATA input)
{
    VS_DATA output = input;
    output.pos = mul(float4(input.pos, 1.f), gWorld).xyz;
    return output;
}

//--------------------------------------------------------------------------------------
// Geometry Shader
//--------------------------------------------------------------------------------------

void TransformVertex(inout TriangleStream<GS_DATA> triStream, float3 pos, float4 col, float3 normal)
{
    GS_DATA data;
    data.pos = mul(float4(pos, 1.f), gViewProj);
    data.color = col;
    data.normal = normal;
    triStream.Append(data);
}

void BoundingBox(float3 v0, float3 v1, float3 v2, out float3 minBound, out float3 maxBound)
{
    minBound = min(min(v0, v1), v2);
    maxBound = max(max(v0, v1), v2);
}

void ResizeBoundingBox(inout float3 minBound, inout float3 maxBound)
{
    int3 minTemp = floor(minBound / float3(gVoxelSize, gVoxelSize, gVoxelSize));
    minBound = (float3)minTemp * gVoxelSize;
    int3 maxTemp = ceil(maxBound / float3(gVoxelSize, gVoxelSize, gVoxelSize));
    maxBound = (float3) maxTemp * gVoxelSize;
}

void GenerateBox(inout TriangleStream<GS_DATA> triStream, float3 minBound, float3 maxBound, float4 color)
{
	//front
    float3 p0 = float3(minBound.x, maxBound.y, minBound.z);
    float3 p1 = float3(minBound.x, minBound.y, minBound.z);
    float3 p2 = float3(maxBound.x, maxBound.y, minBound.z);
    float3 p3 = float3(maxBound.x, minBound.y, minBound.z);

    TransformVertex(triStream, p0, color, float3(0.f, 0.f, -1.f));
    TransformVertex(triStream, p1, color, float3(0.f, 0.f, -1.f));
    TransformVertex(triStream, p2, color, float3(0.f, 0.f, -1.f));
    TransformVertex(triStream, p3, color, float3(0.f, 0.f, -1.f));
    triStream.RestartStrip();

	//back
    p0 = float3(minBound.x, maxBound.y, maxBound.z);
    p1 = float3(minBound.x, minBound.y, maxBound.z);
    p2 = float3(maxBound.x, maxBound.y, maxBound.z);
    p3 = float3(maxBound.x, minBound.y, maxBound.z);

    TransformVertex(triStream, p0, color, float3(0.f, 0.f, 1.f));
    TransformVertex(triStream, p1, color, float3(0.f, 0.f, 1.f));
    TransformVertex(triStream, p2, color, float3(0.f, 0.f, 1.f));
    TransformVertex(triStream, p3, color, float3(0.f, 0.f, 1.f));
    triStream.RestartStrip();

	//left
    p0 = float3(minBound.x, minBound.y, maxBound.z);
    p1 = float3(minBound.x, minBound.y, minBound.z);
    p2 = float3(minBound.x, maxBound.y, maxBound.z);
    p3 = float3(minBound.x, maxBound.y, minBound.z);

    TransformVertex(triStream, p0, color, float3(-1.f, 0.f, 0.f));
    TransformVertex(triStream, p1, color, float3(-1.f, 0.f, 0.f));
    TransformVertex(triStream, p2, color, float3(-1.f, 0.f, 0.f));
    TransformVertex(triStream, p3, color, float3(-1.f, 0.f, 0.f));
    triStream.RestartStrip();

	//right
    p0 = float3(maxBound.x, minBound.y, maxBound.z);
    p1 = float3(maxBound.x, minBound.y, minBound.z);
    p2 = float3(maxBound.x, maxBound.y, maxBound.z);
    p3 = float3(maxBound.x, maxBound.y, minBound.z);

    TransformVertex(triStream, p0, color, float3(1.f, 0.f, 0.f));
    TransformVertex(triStream, p1, color, float3(1.f, 0.f, 0.f));
    TransformVertex(triStream, p2, color, float3(1.f, 0.f, 0.f));
    TransformVertex(triStream, p3, color, float3(1.f, 0.f, 0.f));
    triStream.RestartStrip();

	//bottom
    p0 = float3(minBound.x, minBound.y, maxBound.z);
    p1 = float3(minBound.x, minBound.y, minBound.z);
    p2 = float3(maxBound.x, minBound.y, maxBound.z);
    p3 = float3(maxBound.x, minBound.y, minBound.z);

    TransformVertex(triStream, p0, color, float3(0.f, -1.f, 0.f));
    TransformVertex(triStream, p1, color, float3(0.f, -1.f, 0.f));
    TransformVertex(triStream, p2, color, float3(0.f, -1.f, 0.f));
    TransformVertex(triStream, p3, color, float3(0.f, -1.f, 0.f));
    triStream.RestartStrip();

	//top
    p0 = float3(minBound.x, maxBound.y, maxBound.z);
    p1 = float3(minBound.x, maxBound.y, minBound.z);
    p2 = float3(maxBound.x, maxBound.y, maxBound.z);
    p3 = float3(maxBound.x, maxBound.y, minBound.z);

    TransformVertex(triStream, p0, color, float3(0.f, 1.f, 0.f));
    TransformVertex(triStream, p1, color, float3(0.f, 1.f, 0.f));
    TransformVertex(triStream, p2, color, float3(0.f, 1.f, 0.f));
    TransformVertex(triStream, p3, color, float3(0.f, 1.f, 0.f));
    triStream.RestartStrip();
}

[maxvertexcount(36)]
void GS(triangle VS_DATA vertex[3], inout TriangleStream<GS_DATA> triStream)
{
    VS_DATA vert0 = vertex[0];
    VS_DATA vert1 = vertex[1];
    VS_DATA vert2 = vertex[2];

    if (gShowMesh)
    {
        TransformVertex(triStream, vert0.pos, vertex[0].color, vert0.normal);
        TransformVertex(triStream, vert1.pos, vertex[1].color, vert1.normal);
        TransformVertex(triStream, vert2.pos, vertex[2].color, vert2.normal);
    }
    else
    {
        float4 color = (vert0.color + vert1.color + vert2.color) / .3f;
        float3 minBound, maxBound;
        BoundingBox(vert0.pos, vert1.pos, vert2.pos, minBound, maxBound);
	
        if (gShowBoundingBoxes)
        {
            GenerateBox(triStream, minBound, maxBound, color);
        }
        else
        {
            ResizeBoundingBox(minBound, maxBound);
            GenerateBox(triStream, minBound, maxBound, color);
        }

    }
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS(GS_DATA input) : SV_TARGET
{

    float3 color_rgb = input.color.rgb;
	
    float diffuseStrength = saturate(dot(input.normal, -normalize(gLightDirection)) * .5f + .5f);
    color_rgb = color_rgb * diffuseStrength;
	
    //return float4(color_rgb, input.color.a);
    return float4(diffuseStrength, diffuseStrength, diffuseStrength, 1.f);
}

//--------------------------------------------------------------------------------------
// Technique
//--------------------------------------------------------------------------------------
technique11 Default
{
    pass P0
    {
        SetRasterizerState(NoCulling);
        SetDepthStencilState(EnableDepth, 0);

        SetVertexShader(CompileShader(vs_5_0, VS()));
        SetGeometryShader(CompileShader(gs_5_0, GS()));
        SetPixelShader(CompileShader(ps_5_0, PS()));
    }
}

