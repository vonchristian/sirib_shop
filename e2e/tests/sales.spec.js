// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn, csrfToken } = require('./helpers');

const stamp = Date.now().toString().slice(-6);

test.describe('Sales', () => {
  test.beforeEach(async ({ page }) => {
    await signIn(page);
  });

  test('creates a cart, adds a line, checks out to a sales order, and records a payment', async ({ page }) => {
    // Open a new cart
    await page.goto('/carts/new');
    await page.getByLabel('Store location').selectOption({ label: 'Main Store' });
    await page.getByRole('button', { name: 'Open cart' }).click();
    await expect(page.getByText('Cart opened.')).toBeVisible();

    // Grab the cart id from the URL and add a line via the API
    const url = page.url();
    const cartId = url.match(/\/carts\/(\d+)/)[1];
    const token = await csrfToken(page);

    const response = await page.request.post(`/carts/${cartId}/add_line`, {
      headers: { 'X-CSRF-Token': token, 'Content-Type': 'application/x-www-form-urlencoded' },
      data: 'product_variant_id=1&quantity=1',
    });
    expect(response.ok()).toBeTruthy();

    // Navigate back to the cart to see the line and the Checkout button
    await page.goto(`/carts/${cartId}`);
    await expect(page.getByText('IP15P-128')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Checkout' }).first()).toBeVisible();

    // Checkout converts cart -> sales order (draft)
    await page.getByRole('button', { name: 'Checkout' }).first().click();
    await expect(page.getByText('Cart converted to sales order.')).toBeVisible();
    await expect(page.getByRole('link', { name: 'Record payment' })).toBeVisible();

    // Record a bank transfer payment in full (no cash session needed)
    await page.getByRole('link', { name: 'Record payment' }).click();
    await page.getByLabel('Payment method').selectOption('bank_transfer');
    await page.getByLabel('Amount').fill('25.00');
    await page.getByRole('button', { name: 'Record payment' }).click();
    await expect(page.getByText('Payment recorded.')).toBeVisible();
    await expect(page.getByText('Balance').first()).toBeVisible();
  });

  test('posts a sale and updates inventory', async ({ page }) => {
    // Seed an order with an outstanding balance via API
    await page.goto('/carts');
    const token = await csrfToken(page);
    const createRes = await page.request.post('/carts', {
      headers: { 'X-CSRF-Token': token, 'Content-Type': 'application/x-www-form-urlencoded' },
      data: 'cart[store_location_id]=1&cart[customer_id]=',
    });
    expect(createRes.ok()).toBeTruthy();
    const cartUrl = createRes.url();
    const cartId = cartUrl.match(/\/carts\/(\d+)/)[1];
    await page.request.post(`/carts/${cartId}/add_line`, {
      headers: { 'X-CSRF-Token': token, 'Content-Type': 'application/x-www-form-urlencoded' },
      data: 'product_variant_id=1&quantity=1',
    });
    await page.goto(`/carts/${cartId}`);
    await page.getByRole('button', { name: 'Checkout' }).first().click();
    await expect(page.getByText('Cart converted to sales order.')).toBeVisible();

    // Post the sale
    await page.getByRole('button', { name: 'Post sale' }).click();
    await expect(page.getByText('Sale posted; inventory updated.')).toBeVisible();
  });
});
