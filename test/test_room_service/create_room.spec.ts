import { test, expect } from '@playwright/test';

test('admin vê botão e navega pra criar grupo', async ({ page }) => {
  await page.goto('http://localhost:8080');
  await page.waitForTimeout(3000);
  console.log(await page.content());

 
  await page.fill('input[type="text"]', 'livia@gmail.com');
  await page.fill('input[type="password"]', 'SUA_SENHA');

  await page.click('text=Entrar');


  await page.waitForLoadState('networkidle');

  await page.goto('http://localhost:8080/#/rooms/discover');

  const novoGrupo = page.getByText('Novo Grupo');

  await expect(novoGrupo).toBeVisible({ timeout: 15000 });

  await novoGrupo.click();

  await expect(page.getByText('Criar grupo')).toBeVisible();
});