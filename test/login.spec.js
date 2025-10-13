// @ts-check
const { test, expect } = require('@playwright/test');

test('Login en HRApp y abrir página de Empleados', async ({ page }) => {
  // 🌐 Ir al login
  await page.goto('http://localhost:5173/login');

  // ⌨️ Completar usuario y contraseña
  await page.fill('input[name="username"]', 'admin');
  await page.fill('input[name="password"]', 'admin123');

  // 🚀 Clic en el botón de login
  await page.click('button:has-text("ログイン"), button:has-text("Iniciar sesión")');

  // ⏳ Esperar a que cargue el dashboard
  await page.waitForTimeout(2000);

  // 🧾 Verificar título o texto de la página
  await expect(page).toHaveTitle(/Empleados|社員|Dashboard/i);

  // 📸 Guardar captura del resultado
  await page.screenshot({ path: 'tests/login_result.png' });
});
