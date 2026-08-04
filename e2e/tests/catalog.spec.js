// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn } = require('./helpers');

const stamp = Date.now().toString().slice(-6);

test.describe('Catalog', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('creates a product', async ({ page }) => {
    const name = `E2E Product ${stamp}`;
    await page.goto('/products/new');
    await page.getByLabel('Name').fill(name);
    await page.getByLabel('Brand').fill('Acme');
    await page.getByLabel('Status').selectOption('active');
    await page.getByRole('button', { name: 'Create product' }).click();

    await expect(page.getByText('Product created.')).toBeVisible();
    await expect(page.getByRole('heading', { name })).toBeVisible();
  });

  test('creates a variant for a product', async ({ page }) => {
    await page.goto('/products');
    const productRow = page.locator('tbody tr').filter({ hasText: 'iPhone 15 Pro' }).first();
    await productRow.getByRole('link', { name: 'View' }).click();

    await page.getByRole('link', { name: 'New variant' }).click();
    const sku = `E2E-${stamp}`;
    await page.getByLabel('Variant name').fill(`E2E Variant ${stamp}`);
    await page.getByLabel('SKU').fill(sku);
    await page.getByLabel('Selling price').fill('1500.00');
    await page.getByLabel('Cost price').fill('1000.00');
    await page.getByRole('button', { name: 'Create variant' }).click();

    await expect(page.getByText('Variant created.')).toBeVisible();
    await expect(page.getByText(sku)).toBeVisible();
  });

  test('creates a category', async ({ page }) => {
    await page.goto('/categories/new');
    const name = `E2E Category ${stamp}`;
    await page.getByLabel('Name').fill(name);
    await page.getByRole('button', { name: 'Create category' }).click();

    await expect(page.getByText('Category created.')).toBeVisible();
    await expect(page.getByRole('heading', { name })).toBeVisible();
  });

  test('lists seeded catalog', async ({ page }) => {
    await page.goto('/products');
    await expect(page.getByRole('link', { name: 'iPhone 15 Pro' }).first()).toBeVisible();
    await expect(page.getByRole('link', { name: 'Tempered Glass' }).first()).toBeVisible();

    await page.goto('/product_variants');
    await expect(page.getByText('IP15P-128').first()).toBeVisible();
    await expect(page.getByText('SGS24-256').first()).toBeVisible();

    await page.goto('/stocks');
    await expect(page.locator('tbody').getByText('Tempered Glass - Universal 0.3mm').first()).toBeVisible();
  });
});
