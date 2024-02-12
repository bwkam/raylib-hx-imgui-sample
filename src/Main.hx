class Main {
	static function main() {
		Rl.initWindow(1280, 720, "raylib-hx || Basic Window");
		while (!Rl.windowShouldClose()) {
			Rl.beginDrawing();
			Rl.clearBackground(Rl.Colors.RED);

			// RlImGui.imGuiBegin();

			// RlImGui.imGuiEnd();

			Rl.endDrawing();
		}
		// RlImGui.imGuiShutdown();
		Rl.closeWindow();
	}
}
