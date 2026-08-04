// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn } = require('./helpers');

const stamp = Date.now().toString().slice(-6);

test.describe('Service / Repair', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('lists seeded work order and service assets', async ({ page }) => {
    await page.goto('/work_orders');
    await expect(page.getByRole('link', { name: 'WO-DEMO' }).first()).toBeVisible();

    await page.goto('/service_assets');
    await expect(page.getByText('iPhone 15 Pro').first()).toBeVisible();

    await page.goto('/service_asset_categories');
    await expect(page.getByRole('link', { name: 'Phone' }).first()).toBeVisible();
    await expect(page.getByRole('link', { name: 'Motorcycle' }).first()).toBeVisible();
  });

  test('creates a work order for the seeded asset', async ({ page }) => {
    await page.goto('/work_orders/new');
    await page.getByLabel('Location').selectOption({ label: 'Main Store' });
    await page.getByLabel('Service asset').selectOption({ label: 'iPhone 15 Pro (Phone)' });
    await page.getByLabel('Complaint').fill(`E2E complaint ${stamp}`);

    await page.locator('[name="work_order[services][][name]"]').fill('Battery replacement');
    await page.locator('[name="work_order[services][][unit_price]"]').fill('1500.00');

    await page.getByRole('button', { name: 'Create work order' }).click();

    await expect(page.getByText('Work order created.')).toBeVisible();
    await expect(page.getByRole('heading', { name: /WO-\d{8}-\d{4}/ })).toBeVisible();
    await expect(page.getByText('Battery replacement')).toBeVisible();
  });

  test('walks a work order through the lifecycle', async ({ page }) => {
    // Auto-accept confirm dialogs
    page.on('dialog', (dialog) => dialog.accept());

    // Create a fresh work order so the lifecycle starts at received
    await page.goto('/work_orders/new');
    await page.getByLabel('Location').selectOption({ label: 'Main Store' });
    await page.getByLabel('Service asset').selectOption({ label: 'iPhone 15 Pro (Phone)' });
    await page.getByLabel('Complaint').fill(`E2E lifecycle ${stamp}`);
    await page.getByRole('button', { name: 'Create work order' }).click();
    await expect(page.getByText('Work order created.')).toBeVisible();

    // Walk received -> ready_for_release
    const order = [
      'Diagnosing',
      'Waiting For Approval',
      'Approved',
      'In Progress',
      'Ready For Release',
    ];
    for (const label of order) {
      const button = page.getByRole('button', { name: new RegExp(`^${label}$`) });
      await expect(button).toBeVisible();
      await button.click();
      await expect(page.getByText(`Work order moved to ${label}.`)).toBeVisible({ timeout: 10000 });
    }

    // Receive an item with the asset
    await page.locator('[name="service_item[name]"]').fill('Charger');
    await page.getByRole('button', { name: 'Tag & receive item' }).click();
    await expect(page.getByText('Received item tagged.')).toBeVisible();
    await expect(page.getByText('0/1 returned')).toBeVisible();

    // Release is blocked until the item is returned
    const releaseBtn = page.getByRole('button', { name: 'Released' });
    await releaseBtn.click();
    await expect(page.getByText(/all received items must be returned/i)).toBeVisible({ timeout: 10000 });

    // Return the item, then release succeeds
    await page.getByRole('button', { name: 'Return' }).first().click();
    await expect(page.getByText('Item returned.')).toBeVisible();
    await expect(page.getByText('1/1 returned')).toBeVisible();

    await page.getByRole('button', { name: 'Released' }).click();
    await expect(page.getByText('Work order moved to Released.')).toBeVisible({ timeout: 10000 });
  });

  test('creates a service asset with typed fields', async ({ page }) => {
    await page.goto('/service_assets/new');
    await page.getByLabel('Customer').selectOption({ label: 'Juan Dela Cruz' });
    await page.getByLabel('Category').selectOption({ label: 'Phone' });
    const name = `E2E Asset ${stamp}`;
    await page.getByLabel('Name').fill(name);

    // Category fields appear for Phone: brand, model, storage, color
    const group = page.locator('[data-category-fields-target="group"]:not([hidden])');
    await group.getByLabel('Brand').fill('Apple');
    await group.getByLabel('Model').fill('iPhone 13');
    await group.getByLabel('Storage').fill('128GB');
    await page.getByRole('button', { name: 'Create service asset' }).click();

    await expect(page.getByText('Service asset created.')).toBeVisible();
    await expect(page.getByRole('heading', { name })).toBeVisible();
  });

  test('creates a service asset category with fields', async ({ page }) => {
    await page.goto('/service_asset_categories/new');
    const name = `E2E Category ${stamp}`;
    await page.getByLabel('Name').fill(name);
    await page.getByRole('button', { name: 'Create category' }).click();

    await expect(page.getByText('Category created.')).toBeVisible();

    // Add a field
    await page.goto(`/service_asset_categories`);
    await page.getByRole('link', { name }).first().click();
    await page.getByRole('link', { name: 'Add field' }).click();
    await page.getByLabel('Field name').fill(`e2e_field_${stamp}`);
    await page.getByLabel('Label').fill(`E2E Field ${stamp}`);
    await page.getByRole('button', { name: 'Create field' }).click();
    await expect(page.getByText('Field added.')).toBeVisible();
  });
});
