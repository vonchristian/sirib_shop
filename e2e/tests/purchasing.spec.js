// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn } = require('./helpers');

const stamp = Date.now().toString().slice(-6);

test.describe('Purchasing & Operations', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('creates a purchase order and moves it to received', async ({ page }) => {
    await page.goto('/purchase_orders/new');
    await page.getByLabel('Supplier').selectOption({ label: 'TechSource Distributors' });
    await page.getByLabel('Destination location').selectOption({ label: 'Main Store' });
    await page.locator('[name="purchase_order[lines][][product_variant_id]"]').selectOption({ label: 'Tempered Glass - Universal 0.3mm' });
    await page.locator('[name="purchase_order[lines][][quantity]"]').fill('10');
    await page.locator('[name="purchase_order[lines][][unit_cost]"]').fill('50.00');
    await page.getByRole('button', { name: 'Create purchase order' }).click();

    await expect(page.getByText('Purchase order created.')).toBeVisible();
    await expect(page.getByText(/PO-\d{8}-\d{4}/)).toBeVisible();

    await page.getByRole('button', { name: 'Submit' }).click();
    await expect(page.getByText('Purchase order submitted.')).toBeVisible();

    await page.getByRole('button', { name: 'Approve' }).click();
    await expect(page.getByText('Purchase order approved.')).toBeVisible();

    await page.getByRole('link', { name: 'Receive goods' }).click();
    await expect(page.getByRole('heading', { name: /Receive/i })).toBeVisible();
  });

  test('creates a transfer order', async ({ page }) => {
    await page.goto('/transfer_orders/new');
    await page.getByLabel('Origin location').selectOption({ label: 'Main Store' });
    await page.getByLabel('Destination location').selectOption({ label: 'Ayala Branch' });
    await page.locator('[name="transfer_order[lines][][product_variant_id]"]').selectOption({ label: 'Tempered Glass - Universal 0.3mm' });
    await page.locator('[name="transfer_order[lines][][quantity]"]').fill('3');
    await page.getByRole('button', { name: 'Create transfer' }).click();

    await expect(page.getByText('Transfer order created.')).toBeVisible();
  });

  test('creates a supplier', async ({ page }) => {
    await page.goto('/suppliers/new');
    const name = `E2E Supplier ${stamp}`;
    await page.getByLabel('Name').fill(name);
    await page.getByRole('button', { name: 'Create supplier' }).click();

    await expect(page.getByText('Supplier created.')).toBeVisible();
    await expect(page.getByRole('heading', { name })).toBeVisible();
  });
});
