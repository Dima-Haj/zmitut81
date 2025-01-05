module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    "ecmaVersion": 2020,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    // "linebreak-style": ["error", "unix"],
    // If you want to allow both styles:
    "linebreak-style": ["off"],
    "max-len": "off",
    "indent": "off",
    "no-trailing-spaces": "off",
    "padded-blocks": "off",
    "object-curly-spacing": ["off"], // Disable spacing rule for object braces
    "comma-dangle": ["off"], // Disable trailing comma rule
    "no-unused-vars": ["warn"], // Change unused vars to a warning
    "quotes": ["off"],
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
