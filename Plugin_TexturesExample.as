#name "Textures Example"
#author "XertroV"
#category "Examples"

/*
  This example covers loading textures.

  todo: this requires Openplanet v1.24.0 so probs shouldn't be merged before then.
  todo: until that time it's here without comments b/c it's probably useful.

  We'll download Openplanet.dev's high-res favicon and display it.

  Relevant docs:
  - https://openplanet.dev/docs/api/Net
  - https://openplanet.dev/docs/api/Net/HttpRequest
*/

// URL for Openplanet.dev's favicon
const string FAVICON_URL = "https://openplanet.dev/img/apple-touch-icon.png";

void Main() {
  @faviconTex = GetFaviconTex();
  print("If you don't see the big, beating Openheart logo in the background, make sure no windows are in front of the middle of your screen.");
}

void Render() {
  if (faviconTex is null) return;
  RenderMainWindow();
  RenderNvgTexture();
}

class BothTextures {
  UI::Texture@ uiTex;
  nvg::Texture@ nvgTex;
  BothTextures (UI::Texture@ uiTex, nvg::Texture@ nvgTex) {
    @this.uiTex = uiTex;
    @this.nvgTex = nvgTex;
  }
}

BothTextures@ faviconTex;

BothTextures@ GetFaviconTex() {
    auto req = Net::HttpGet(FAVICON_URL);
    req.Headers['User-Agent'] = "AngelScriptExample (Textures)/Plugin.ID: " + Meta::ExecutingPlugin().ID;
    req.Start();
    while (!req.Finished()) yield();
    if (req.ResponseCode() >= 300) {
      throw("Unknown response code: " + req.ResponseCode());
    }
    auto data = req.Buffer();
    print("TextureExample got texture of length: " + data.GetSize());

    return BothTextures(UI::LoadTexture(data), nvg::LoadTexture(data));
}

void RenderMainWindow() {
  vec2 size = faviconTex.uiTex.GetSize();
  if (UI::Begin("Texture Test", GetWindowFlags())) {
    UI::Text("UI::Image Demo");
    UI::Image(faviconTex.uiTex);
    UI::Text("" + size.x + " x " + size.y + " px");
    UI::End();
  }
}

int GetWindowFlags() {
  return UI::WindowFlags::NoTitleBar
    | UI::WindowFlags::NoCollapse
    | UI::WindowFlags::AlwaysAutoResize
    | UI::WindowFlags::NoDecoration
    ;
}

void RenderNvgTexture() {
  vec2 screen = vec2(Draw::GetWidth(), Draw::GetHeight());
  vec2 size = faviconTex.nvgTex.GetSize();

  // some animation
  float t = float(Time::Now) / 1000.;
  float alpha = Math::Sin(t * 2.); // range: [-1, 1]
  alpha = Math::Pow(alpha, 8.); // map to 0,1 and amplify peaks
  float alphaW = alpha / 2. + 1.;
  float alphaH = alpha / 3. + 1.;
  vec2 newSize = size * vec2(alphaW, alphaH) * 3.;
  vec2 pos = (screen - newSize) / 2.;

  nvg::BeginPath();
  nvg::Rect(pos, newSize);
  // todo: not sure what all of these arguments are
  nvg::FillPaint(nvg::TexturePattern(pos, newSize, 0, faviconTex.nvgTex, 1));
  nvg::Fill();
}
