
# Contributing to SocialSphere

Thank you for your interest in contributing to **SocialSphere**! 🎉 We welcome contributions that help improve our platform and community. Before you begin, please take a moment to review these guidelines to ensure a smooth contribution process.

## 💬 Connect With Us

For questions, discussions, or to propose new ideas, feel free to reach out through issues or pull requests. If available, join our community channels for real-time discussions.

## 🛠 Development Environment Setup

To set up a local development environment, follow these steps:

1. **Fork the repository** from [https://github.com/ZencypherSolutions/socialsphere](https://github.com/ZencypherSolutions/socialsphere).
2. **Clone your forked repository**:

   ```bash
   git clone https://github.com/yourusername/socialsphere.git
   cd socialsphere
   ```

3. **Install dependencies**:

   ```bash
   npm install
   # or
   yarn install
   # or
   pnpm install
   ```

4. **Run the development server**:

   ```bash
   npm run dev
   ```

The project will run at [http://localhost:3000](http://localhost:3000).

### 📁 Project Structure

```
socialsphere/
├── app/              # Next.js app directory
├── components/       # Reusable UI components
├── lib/              # Utility functions and shared logic
├── public/           # Static assets
└── styles/           # Global styles and Tailwind CSS
```

## 🚀 Issues and Feature Requests

Found a bug? Have a feature suggestion? Help us improve SocialSphere by submitting an issue.

### 📌 Creating an Issue

Before opening a new issue, please check if it already exists in the issue tracker.

When reporting a bug or suggesting a feature:
- **Reproducible**: Include clear steps to reproduce the issue.
- **Detailed**: Provide version info, screenshots, or logs if applicable.
- **Specific**: Keep each issue focused on a single topic or problem.

## 🏗 How to Contribute

1. **Fork the repository** from [https://github.com/ZencypherSolutions/socialsphere](https://github.com/ZencypherSolutions/socialsphere).
2. **Clone your forked repository**:

   ```bash
   git clone https://github.com/yourusername/socialsphere.git
   cd socialsphere
   ```

3. **Create a new branch** for your feature or bugfix:

   ```bash
   git checkout -b feat/[issue-number]-[your-feature-name]
   ```

4. **Make your changes** following the project’s coding standards.
5. **Commit your changes** with clear and descriptive messages:

   ```bash
   git commit -m "feat: add new DAO voting mechanism"
   ```

6. **Push your branch** to your forked repository:

   ```bash
   git push origin feat/[issue-number]-[your-feature-name]
   ```

7. **Before submitting a Pull Request,** review the guidelines in our [Pull Request Template](PULL_REQUEST_TEMPLATE.md) on how to structure it.


## 📏 Coding Standards

- **Language**: TypeScript
- **Framework**: Next.js 15
- **Styling**: Tailwind CSS with Radix UI components
- **Linting**: Follow ESLint rules (`npm run lint`)
- **Commit Messages**: Use [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
  - `feat:` for new features
  - `fix:` for bug fixes
  - `refactor:` for code changes that don’t add features or fix bugs  
  - `chore:` for maintenance work
  - `docs:` for documentation changes
- **Code Formatting**: 
  - Use **Prettier** for consistent code formatting (`npm run format`).
  - Maintain consistent **indentation**, **spacing**, and **code structure**.
  - Avoid **unused variables** and **imports**.


## ✅ Pull Request Checklist

Before submitting a pull request, please ensure that:
- [ ] Your code follows the project’s coding conventions.
- [ ] You’ve added relevant tests for new features or bug fixes.
- [ ] Your code passes all existing tests (`npm run test` if available).
- [ ] Documentation has been updated as needed.

## 🏷 Understanding Pull Request Labels

- **Ready for Review**: PR is complete and awaiting review.
- **In Progress – Do Not Merge**: Still a work in progress.
- **Changes Requested**: Maintainers have requested updates before merging.

## 🌟 Community Guidelines

Please review our [Code of Conduct](CODE_OF_CONDUCT.md) to foster a respectful and inclusive environment.

##
We appreciate your contributions and look forward to building an incredible platform for decentralized organizations together! 🚀