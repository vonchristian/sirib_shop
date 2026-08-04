// @ts-check
const { expect } = require('@playwright/test');

/**
 * Shared e2e helpers.
 */

const MANAGER = {
  email: 'manager@cellshop.example',
  password: 'password123',
  name: 'Manager',
};

async function signIn(page, user = MANAGER) {
  await page.goto('/login');
  await page.getByLabel('Email address').fill(user.email);
  await page.getByLabel('Password').fill(user.password);
  await page.getByRole('button', { name: 'Sign in' }).click();
  await expect(page).toHaveURL('/');
  await expect(page.getByRole('heading', { name: /dashboard/i })).toBeVisible();
}

async function signOut(page) {
  await page.locator('.hs-dropdown-toggle').first().click();
  await page.getByText('Sign out').click();
  await expect(page).toHaveURL(/login/);
}

/**
 * Click a sidebar nav link by its exact text.
 */
async function gotoSection(page, label) {
  await page.locator('a', { hasText: label }).first().click();
}

async function openNewViaHeader(page, buttonText) {
  await page.getByRole('link', { name: buttonText }).first().click();
}

/**
 * Fetch the CSRF token from the current page's meta tags.
 */
async function csrfToken(page) {
  const token = await page.locator('meta[name="csrf-token"]').getAttribute('content');
  if (!token) throw new Error('No CSRF token found on page');
  return token;
}

module.exports = { MANAGER, signIn, signOut, gotoSection, csrfToken };
