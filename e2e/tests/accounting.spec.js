// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn } = require('./helpers');

const stamp = Date.now().toString().slice(-6);

test.describe('Accounting', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('lists ledgers and posts a journal entry', async ({ page }) => {
    await page.goto('/ledgers');
    await expect(page.getByRole('link', { name: /General Ledger/ }).first()).toBeVisible();

    // Post a manual entry to the general ledger
    await page.goto('/journal_entries/new');
    await page.getByLabel('Description').fill(`E2E adjustment ${stamp}`);
    const selects = page.locator('select[name*="account_id"]');
    await selects.nth(0).selectOption({ label: '1100 · Cash' });
    await selects.nth(1).selectOption({ label: '1200 · Accounts Receivable' });
    await page.locator('input[name*="[debit]"]').nth(0).fill('50.00');
    await page.locator('input[name*="[credit]"]').nth(1).fill('50.00');
    await page.getByRole('button', { name: 'Post entry' }).click();

    await expect(page.getByText('Journal entry posted.')).toBeVisible();
    await expect(page.getByText(`E2E adjustment ${stamp}`)).toBeVisible();
  });

  test('creates a customer', async ({ page }) => {
    await page.goto('/customers/new');
    await page.getByLabel('Name').fill(`E2E Customer ${stamp}`);
    await page.getByRole('button', { name: 'Create customer' }).click();
    await expect(page.getByText('Customer created.')).toBeVisible();
    await expect(page.getByRole('heading', { name: `E2E Customer ${stamp}` })).toBeVisible();
  });

  test('creates a user', async ({ page }) => {
    await page.goto('/users/new');
    await page.getByLabel('Name').fill(`E2E User ${stamp}`);
    await page.getByLabel('Email').fill(`e2e_${stamp}@example.com`);
    await page.getByLabel('Password', { exact: true }).fill('password123');
    await page.getByLabel('Confirm password').fill('password123');
    await page.getByRole('button', { name: 'Create user' }).click();
    await expect(page.getByText('User created.')).toBeVisible();
    await expect(page.getByRole('heading', { name: `E2E User ${stamp}` })).toBeVisible();
  });
});
