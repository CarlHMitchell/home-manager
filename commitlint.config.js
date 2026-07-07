module.exports = {
  extends: ["@commitlint/config-conventional"],
  rules: {
    // Type must be one of these
    "type-enum": [
      2,
      "always",
      [
        "feat", // New feature
        "fix", // Bug fix
        "docs", // Documentation only changes
        "style", // Changes that don't affect code meaning (formatting, etc)
        "refactor", // Code change that neither fixes a bug nor adds a feature
        "perf", // Performance improvement
        "test", // Adding or updating tests
        "chore", // Changes to build process or auxiliary tools
        "revert", // Revert a previous commit
        "build", // Changes to build system or dependencies
        "ci", // Changes to CI configuration
      ],
    ],

    "scope-empty": [0],
    "scope-case": [1, "always", "upper-case"],

    // Do not enforce subject casing — prevents false failures on valid technical
    // terms (IAM, SQL, HTTP/2, etc.). Conventional lowercase imperative style
    // is enforced via PR review.
    "subject-case": [0],

    "subject-full-stop": [0, "never", "."],

    // Subject and type must not be empty
    "subject-empty": [2, "never"],
    "type-empty": [2, "never"],

    "header-max-length": [1, "always", 50],
    "body-max-line-length": [1, "always", 200],
    "footer-max-line-length": [1, "always", 200],
  },
  plugins: [
    {
      rules: {
      },
    },
  ],
  ignores: [
    // Example: skip Copilot agent "Initial Plan" commit(s)
    (msg) => msg.split("\n")[0].trim().toLowerCase() === "initial plan",
  ],
};
