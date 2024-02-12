{
  description = "A Nix-flake-based Haxe development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs = { nixgl.url = "github:guibou/nixGL"; };

  outputs = { self, nixpkgs, nixgl }:
    let

      supportedSystems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forEachSupportedSystem = f:
        nixpkgs.lib.genAttrs supportedSystems (system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [
                nixgl.overlay

                (self: super:  {
                  rlImGui = super.stdenv.mkDerivation {
                    name = "rlImGui";
                    version = "latest";
                    src = self.fetchFromGitHub {
                      owner = "raylib-extras";
                      repo = "rlImGui";
                      rev = "777a3375723eff6a6f4ac4568a1344f1f6e99315";
                      sha256 =
                        "sha256-bslVgevpwUPze+2DHZdecogVnyK2vk3JiodbZv6Wt48=";
                    };

                    nativeBuildInputs = [ self.premake5 ];
                    buildInputs = [self.imgui self.raylib];
                    postPatch = ''
                      substituteInPlace ./*.cpp ./*.h ./examples/*.cpp ./examples/*.h --replace '#include "imgui.h"' '#include <imgui/imgui.h>'
                      substituteInPlace ./premake5.lua --replace 'includedirs {"./", "imgui", "imgui-master" }' 'includedirs {"./", "${self.imgui}/include/imgui/" }' 
                      substituteInPlace ./premake5.lua --replace 'includedirs { "rlImGui", "imgui", "imgui-master"}' 'includedirs { "${self.rlImGui}", "${self.imgui}/include/imgui/"}'
                      substituteInPlace ./premake5.lua --replace '["ImGui Files"] = { "imgui/*.h","imgui/*.cpp", "imgui-master/*.h","imgui-master/*.cpp" }' \
                        ["ImGui Files"] = { "${self.imgui}/include/imgui/*.h","${self.imgui}/include/imgui/*.cpp" },
                      substituteInPlace ./premake5.lua --replace 'files {"imgui-master/*.h", "imgui-master/*.cpp", "imgui/*.h", "imgui/*.cpp", "*.cpp", "*.h", "extras/**.h"}' \
                        'files {"${self.imgui}/include/imgui/*.h", "${self.imgui}/include/imgui/*.cpp", "*.cpp", "*.h", "extras/**.h"}'

                      cat ./premake5.lua
                    '';
                    # postFixup =
                    #   "mkdir -p $out/include/ && cp ./*.h $out/include/ && mkdir -p $out/include/extras/ && cp ./extras/* $out/include/extras/";
                  };
                })
              ];
            };
          });
    in let

      buildHxml = pkgs:
        pkgs.writeText "build.hxml" ''
          -cp src
          -cpp bin
          -lib raylib-hx
          -main Main.hx
          # -D shared_libs=${pkgs.raylib}
          # -D shared_libs=${pkgs.rlImGui}
        '';

    in {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          shellHook = ''
            ln -s ${buildHxml pkgs} ./build.hxml
          '';
          packages = with pkgs; [
            haxe
            neko
            xorg.libX11
            xorg.libXrandr
            xorg.libXcursor
            xorg.libXinerama
            xorg.xinput
            xorg.libXi
            raylib
            rlImGui
            glfw
            pkgs.nixgl.nixGLIntel
          ];
        };
      });
    };
}
