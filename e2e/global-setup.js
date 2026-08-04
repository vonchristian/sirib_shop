// @ts-check
const { execSync } = require('child_process');

/**
 * Reset dynamic state so each run starts from a deterministic seeded base:
 * close any open cash sessions, abandon open carts.
 */
module.exports = async () => {
  const script = [
    "CashSession.where(status: %i[open closing]).update_all(status: :closed, closed_at: Time.current)",
    "Cart.where(status: :open).update_all(status: :abandoned)",
    "puts 'state reset'",
  ].join('; ');
  try {
    execSync(`bin/rails runner "${script}"`, { cwd: require('path').resolve(__dirname, '..'), stdio: 'pipe' });
  } catch (err) {
    console.warn(`[global-setup] DB reset failed: ${err.message}`);
  }
};
