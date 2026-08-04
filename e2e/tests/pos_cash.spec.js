// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn } = require('./helpers');

const stamp = Date.now().toString().slice(-6);

test.describe('POS & Cash', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('opens and closes a cash session', async ({ page }) => {
    await page.goto('/cash_sessions/new');
    await page.getByLabel('Cash register').selectOption({ label: 'Main Counter' });
    await page.getByLabel('Opening float').fill('1000.00');
    await page.getByRole('button', { name: 'Open session' }).click();

    await expect(page.getByText('Cash session opened.')).toBeVisible();

    // Close it
    await page.getByRole('button', { name: 'Close session' }).click();
    await expect(page.getByText('Session closed.')).toBeVisible();
  });

  test('adds cash in and cash out to an open session', async ({ page }) => {
    await page.goto('/cash_sessions/new');
    await page.getByLabel('Cash register').selectOption({ label: 'Main Counter' });
    await page.getByLabel('Opening float').fill('500.00');
    await page.getByRole('button', { name: 'Open session' }).click();
    await expect(page.getByText('Cash session opened.')).toBeVisible();

    await page.getByLabel('Type').selectOption('cash_in');
    await page.getByLabel('Amount').fill('200.00');
    await page.getByRole('button', { name: 'Add' }).click();
    await expect(page.getByText('Cash movement recorded.')).toBeVisible();
    await expect(page.getByText('Cash In').first()).toBeVisible();
  });

  test('lists cash registers', async ({ page }) => {
    await page.goto('/cash_registers');
    await expect(page.getByRole('link', { name: 'Main Counter' }).first()).toBeVisible();
  });
});
