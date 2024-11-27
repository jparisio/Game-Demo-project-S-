
// NOTE: you can call crystal_debug_show() instead of droping the object in the room!!
debug = new Crystal_DebugUI(origin, classInstance, isOpened, __startMaximized);


// Tests
/*
variable1 = false;
variable2 = 10;
variable3 = false;
variable4 = 10;

uiSystem = new __Crystal_UISystem();
// =====================

inspector1 = new __Crystal_UIInspector();
var _menu1A = inspector1.AddElement(new __Crystal_UIElementSection("TITLE", true));
	inspector1.AddElement(new __Crystal_UIElementCheckbox(self, "variable1"), _menu1A);
	inspector1.AddElement(new __Crystal_UIElementSlider(self, "variable2",, -100, 100), _menu1A);

inspector2 = new __Crystal_UIInspector();
var _menu2A = inspector2.AddElement(new __Crystal_UIElementSection("TITLE", true));
	inspector2.AddElement(new __Crystal_UIElementCheckbox(self, "variable3"), _menu2A);
	inspector2.AddElement(new __Crystal_UIElementSlider(self, "variable4",, -100, 100), _menu2A);


window1 = new __Crystal_UIWindow("AAAA");
window1.xx = 100;
window1.content = inspector1;

window2 = new __Crystal_UIWindow("AAAA");
window2.xx = 200;
window2.content = inspector2;


uiSystem.AddContainer(window1);
uiSystem.AddContainer(window2);
*/
