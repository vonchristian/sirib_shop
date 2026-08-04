// @ts-check
const { test, expect } = require('@playwright/test');
const { signIn, signOut, MANAGER } = require('./helpers');

test.describe('Authentication', () => {
  test('shows the login form and validates credentials', async ({ page }) => {
    await page.goto('/login');
    await expect(page.getByLabel('Email address')).toBeVisible();
    await expect(page.getByLabel('Password')).toBeVisible();

    await page.getByLabel('Email address').fill('nobody@example.com');
    await page.getByLabel('Password').fill('wrongpass');
    await page.getByRole('button', { name: 'Sign in' }).click();

    await expect(page.getByText('Invalid email or password.')).toBeVisible();
    await expect(page).toHaveURL(/login/);
  });

  test('signs in with seeded manager credentials', async ({ page }) => {
    await signIn(page);
    await expect(page.getByText('Welcome, Manager.')).toBeVisible();
  });

  test('signs out', async ({ page }) => {
    await signIn(page);
    await signOut(page);
    await expect(page.getByText('Signed out.')).toBeVisible();
  });

  test('redirects to login when not authenticated', async ({ page }) => {
    await page.goto('/products');
    await expect(page).toHaveURL(/login/);
    await expect(page.getByText('Please sign in with a business account.')).toBeVisible();
  });

  test('redirects already-authenticated users away from login', async ({ page }) => {
    await signIn(page);
    await page.goto('/login');
    await expect(page).toHaveURL('/');
  });
});
