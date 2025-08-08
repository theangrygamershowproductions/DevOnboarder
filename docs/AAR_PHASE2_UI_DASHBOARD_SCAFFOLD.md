# AAR System Phase 2: UI + Dashboard Architecture

## Overview

Building on the bulletproof schema-driven AAR foundation, Phase 2 introduces a complete user interface ecosystem while preserving all schema enforcement and quality guarantees.

## Architecture: UI Layer on Schema Foundation

```text
┌─ Form-Based UI ─────────────────────────────────────────┐
│  React/Tailwind → JSON Data → Schema Validation        │
└─────────────────────────────────────────────────────────┘
┌─ Existing Schema System (Phase 1) ─────────────────────┐
│  JSON Data → Schema Validation → Template → Markdown   │
└─────────────────────────────────────────────────────────┘
┌─ Multi-Format Output ───────────────────────────────────┐
│  Markdown → PDF/HTML/Email + Auto-linking + Dashboard  │
└─────────────────────────────────────────────────────────┘
```

**Key Principle**: The UI layer generates the same JSON that manual creation produces, ensuring identical validation and output quality.

## Component 1: Form-Based UI

### React AAR Form Component

```typescript
// src/components/AAR/AARForm.tsx
import React, { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';

// Zod schema mirroring JSON Schema
const AARSchema = z.object({
  title: z.string().min(5, "Title must be at least 5 characters"),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Use YYYY-MM-DD format"),
  type: z.enum(['Infrastructure', 'CI', 'Monitoring', 'Documentation', 'Feature', 'Security']),
  priority: z.enum(['Critical', 'High', 'Medium', 'Low']),
  participants: z.array(z.string()).optional(),
  executive_summary: z.object({
    problem: z.string().min(10, "Problem description required"),
    solution: z.string().min(10, "Solution description required"),
    outcome: z.string().min(10, "Outcome description required")
  }),
  phases: z.array(z.object({
    name: z.string(),
    duration: z.string().optional(),
    description: z.string(),
    status: z.enum(['Not Started', 'In Progress', 'Completed', 'Blocked', 'Cancelled']).optional()
  })).optional(),
  outcomes: z.object({
    success_metrics: z.array(z.string()).optional(),
    challenges_overcome: z.array(z.string()).optional()
  }).optional(),
  follow_up: z.object({
    action_items: z.array(z.object({
      task: z.string(),
      owner: z.string(),
      due_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
      status: z.enum(['Not Started', 'In Progress', 'Completed', 'Blocked']).optional()
    })).optional(),
    monitoring: z.array(z.string()).optional()
  }).optional(),
  lessons_learned: z.array(z.string()).optional(),
  references: z.array(z.object({
    title: z.string(),
    url: z.string(),
    type: z.enum(['documentation', 'external', 'issue', 'pr']).optional()
  })).optional()
});

type AARFormData = z.infer<typeof AARSchema>;

export function AARForm() {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [generatedFiles, setGeneratedFiles] = useState<string[]>([]);

  const {
    register,
    handleSubmit,
    formState: { errors },
    watch,
    setValue,
    getValues
  } = useForm<AARFormData>({
    resolver: zodResolver(AARSchema),
    defaultValues: {
      date: new Date().toISOString().split('T')[0],
      type: 'Infrastructure',
      priority: 'Medium',
      participants: [],
      phases: [],
      outcomes: { success_metrics: [], challenges_overcome: [] },
      follow_up: { action_items: [], monitoring: [] },
      lessons_learned: [],
      references: []
    }
  });

  const onSubmit = async (data: AARFormData) => {
    setIsSubmitting(true);
    try {
      // Generate AAR using existing schema system
      const response = await fetch('/api/aar/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      });

      if (response.ok) {
        const result = await response.json();
        setGeneratedFiles([result.jsonFile, result.markdownFile]);

        // Optional: Auto-commit to repository
        if (confirm('Commit AAR to repository?')) {
          await fetch('/api/aar/commit', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ files: result.files })
          });
        }
      }
    } catch (error) {
      console.error('AAR generation failed:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="max-w-4xl mx-auto p-6 bg-white shadow-lg rounded-lg">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Create After Action Report</h1>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-8">
        {/* Basic Information */}
        <div className="bg-gray-50 p-6 rounded-lg">
          <h2 className="text-xl font-semibold mb-4">Basic Information</h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Title *</label>
              <input
                {...register('title')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="Clear, descriptive AAR title"
              />
              {errors.title && <p className="text-red-500 text-sm mt-1">{errors.title.message}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Date *</label>
              <input
                type="date"
                {...register('date')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              {errors.date && <p className="text-red-500 text-sm mt-1">{errors.date.message}</p>}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Type *</label>
              <select
                {...register('type')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="Infrastructure">Infrastructure</option>
                <option value="CI">CI</option>
                <option value="Monitoring">Monitoring</option>
                <option value="Documentation">Documentation</option>
                <option value="Feature">Feature</option>
                <option value="Security">Security</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Priority *</label>
              <select
                {...register('priority')}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="Critical">Critical</option>
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
              </select>
            </div>
          </div>
        </div>

        {/* Executive Summary */}
        <div className="bg-gray-50 p-6 rounded-lg">
          <h2 className="text-xl font-semibold mb-4">Executive Summary *</h2>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Problem *</label>
              <textarea
                {...register('executive_summary.problem')}
                rows={3}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="What problem was being addressed?"
              />
              {errors.executive_summary?.problem && (
                <p className="text-red-500 text-sm mt-1">{errors.executive_summary.problem.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Solution *</label>
              <textarea
                {...register('executive_summary.solution')}
                rows={3}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="What approach was taken to solve the problem?"
              />
              {errors.executive_summary?.solution && (
                <p className="text-red-500 text-sm mt-1">{errors.executive_summary.solution.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Outcome *</label>
              <textarea
                {...register('executive_summary.outcome')}
                rows={3}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                placeholder="What was the final result and impact?"
              />
              {errors.executive_summary?.outcome && (
                <p className="text-red-500 text-sm mt-1">{errors.executive_summary.outcome.message}</p>
              )}
            </div>
          </div>
        </div>

        {/* Dynamic Sections */}
        <DynamicParticipants register={register} errors={errors} />
        <DynamicPhases register={register} errors={errors} />
        <DynamicOutcomes register={register} errors={errors} />
        <DynamicFollowUp register={register} errors={errors} />
        <DynamicLessonsLearned register={register} errors={errors} />
        <DynamicReferences register={register} errors={errors} />

        {/* Submit */}
        <div className="flex justify-end space-x-4">
          <button
            type="button"
            onClick={() => console.log('Preview:', getValues())}
            className="px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50"
          >
            Preview JSON
          </button>

          <button
            type="submit"
            disabled={isSubmitting}
            className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50"
          >
            {isSubmitting ? 'Generating AAR...' : 'Generate AAR'}
          </button>
        </div>
      </form>

      {/* Success Message */}
      {generatedFiles.length > 0 && (
        <div className="mt-6 p-4 bg-green-50 rounded-lg">
          <h3 className="text-lg font-medium text-green-800">AAR Generated Successfully!</h3>
          <ul className="mt-2 text-green-700">
            {generatedFiles.map((file, index) => (
              <li key={index}>📄 {file}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
```

### GitHub Issue Forms Integration

```yaml
# .github/ISSUE_TEMPLATE/aar-request.yml
name: 📋 After Action Report Request
description: Request AAR generation for a completed initiative
title: "[AAR] "
labels: ["aar", "documentation"]
body:
  - type: input
    id: title
    attributes:
      label: AAR Title
      description: Clear, descriptive title for the AAR
      placeholder: "Infrastructure Modernization Initiative"
    validations:
      required: true

  - type: dropdown
    id: type
    attributes:
      label: AAR Type
      description: Category of the initiative
      options:
        - Infrastructure
        - CI
        - Monitoring
        - Documentation
        - Feature
        - Security
    validations:
      required: true

  - type: dropdown
    id: priority
    attributes:
      label: Priority Level
      options:
        - Critical
        - High
        - Medium
        - Low
    validations:
      required: true

  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      description: What problem was being addressed?
      placeholder: "Describe the problem that needed to be solved..."
    validations:
      required: true

  - type: textarea
    id: solution
    attributes:
      label: Solution Approach
      description: What approach was taken to solve the problem?
      placeholder: "Describe the solution that was implemented..."
    validations:
      required: true

  - type: textarea
    id: outcome
    attributes:
      label: Outcome and Impact
      description: What was the final result?
      placeholder: "Describe the outcome and impact achieved..."
    validations:
      required: true

  - type: textarea
    id: metrics
    attributes:
      label: Success Metrics
      description: Measurable improvements (one per line)
      placeholder: |
        Performance: 45% improvement in response time
        Reliability: 99.9% uptime achieved
        Cost: 30% reduction in infrastructure spend

  - type: textarea
    id: lessons
    attributes:
      label: Lessons Learned
      description: Key insights for future projects (one per line)
      placeholder: |
        Schema-first approach prevents format inconsistencies
        Automation reduces manual overhead significantly
        Team training investment pays dividends
```

## Component 2: Multi-Format Output System

### Enhanced Renderer with Multiple Outputs

```javascript
// scripts/render_aar_multi.js
const fs = require("fs");
const path = require("path");
const Handlebars = require("handlebars");
const puppeteer = require("puppeteer");
const { marked } = require("marked");

class MultiFormatAARRenderer {
    constructor() {
        this.schemaPath = path.join(__dirname, "../docs/AAR/schema/aar.schema.json");
        this.templatePath = path.join(__dirname, "../docs/AAR/templates/aar.hbs");
        this.htmlTemplatePath = path.join(__dirname, "../docs/AAR/templates/aar.html.hbs");
        this.emailTemplatePath = path.join(__dirname, "../docs/AAR/templates/aar.email.hbs");
    }

    async generateAll(dataPath, outputDir) {
        const data = this.loadAndValidateAAR(dataPath);
        const outputs = {};

        // Generate Markdown (existing)
        outputs.markdown = await this.generateMarkdown(data, outputDir);

        // Generate HTML
        outputs.html = await this.generateHTML(data, outputDir);

        // Generate PDF
        outputs.pdf = await this.generatePDF(data, outputDir);

        // Generate Email
        outputs.email = await this.generateEmail(data, outputDir);

        // Update index with multi-format links
        await this.generateMultiFormatIndex(outputDir);

        return outputs;
    }

    async generateHTML(data, outputDir) {
        const template = fs.readFileSync(this.htmlTemplatePath, "utf8");
        const compiledTemplate = Handlebars.compile(template);

        // Enhanced data with auto-linking
        const enhancedData = await this.enhanceWithAutoLinking(data);

        const html = compiledTemplate(enhancedData);
        const filename = this.getFilename(data, 'html');
        const outputPath = path.join(outputDir, filename);

        fs.writeFileSync(outputPath, html);
        return outputPath;
    }

    async generatePDF(data, outputDir) {
        // Generate HTML first
        const htmlPath = await this.generateHTML(data, outputDir);
        const htmlContent = fs.readFileSync(htmlPath, 'utf8');

        const browser = await puppeteer.launch();
        const page = await browser.newPage();

        await page.setContent(htmlContent, { waitUntil: 'networkidle0' });

        const filename = this.getFilename(data, 'pdf');
        const outputPath = path.join(outputDir, filename);

        await page.pdf({
            path: outputPath,
            format: 'A4',
            printBackground: true,
            margin: {
                top: '20mm',
                right: '20mm',
                bottom: '20mm',
                left: '20mm'
            }
        });

        await browser.close();
        return outputPath;
    }

    async generateEmail(data, outputDir) {
        const template = fs.readFileSync(this.emailTemplatePath, "utf8");
        const compiledTemplate = Handlebars.compile(template);

        const emailHtml = compiledTemplate(data);
        const filename = this.getFilename(data, 'email.html');
        const outputPath = path.join(outputDir, filename);

        fs.writeFileSync(outputPath, emailHtml);
        return outputPath;
    }

    async enhanceWithAutoLinking(data) {
        // Auto-link related PRs, commits, and issues
        const enhancedData = { ...data };

        // GitHub API integration for auto-linking
        if (process.env.GITHUB_TOKEN) {
            try {
                const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

                // Search for related PRs
                const prSearch = await octokit.rest.search.issuesAndPullRequests({
                    q: `repo:${process.env.GITHUB_REPOSITORY} is:pr ${data.title}`,
                    sort: 'updated',
                    order: 'desc'
                });

                // Search for related issues
                const issueSearch = await octokit.rest.search.issuesAndPullRequests({
                    q: `repo:${process.env.GITHUB_REPOSITORY} is:issue ${data.title}`,
                    sort: 'updated',
                    order: 'desc'
                });

                // Add auto-discovered references
                if (!enhancedData.references) enhancedData.references = [];

                prSearch.data.items.slice(0, 5).forEach(pr => {
                    enhancedData.references.push({
                        title: `PR #${pr.number}: ${pr.title}`,
                        url: pr.html_url,
                        type: 'pr'
                    });
                });

                issueSearch.data.items.slice(0, 5).forEach(issue => {
                    enhancedData.references.push({
                        title: `Issue #${issue.number}: ${issue.title}`,
                        url: issue.html_url,
                        type: 'issue'
                    });
                });

            } catch (error) {
                console.warn('Auto-linking failed:', error.message);
            }
        }

        return enhancedData;
    }

    getFilename(data, extension) {
        const sanitizedTitle = data.title
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '');
        return `${data.date}_${sanitizedTitle}.${extension}`;
    }
}
```

## Component 3: AAR Dashboard

### GitHub Pages Dashboard

```typescript
// docs/dashboard/index.tsx (Static site generation)
import React from 'react';
import { GetStaticProps } from 'next.js';

interface AAR {
  title: string;
  date: string;
  type: string;
  priority: string;
  filename: string;
  summary: string;
}

interface DashboardProps {
  aars: AAR[];
  stats: {
    total: number;
    byType: Record<string, number>;
    byPriority: Record<string, number>;
    recentCount: number;
  };
}

export default function AARDashboard({ aars, stats }: DashboardProps) {
  const [filter, setFilter] = useState('');
  const [typeFilter, setTypeFilter] = useState('all');
  const [priorityFilter, setPriorityFilter] = useState('all');

  const filteredAARs = aars.filter(aar => {
    const matchesText = aar.title.toLowerCase().includes(filter.toLowerCase()) ||
                       aar.summary.toLowerCase().includes(filter.toLowerCase());
    const matchesType = typeFilter === 'all' || aar.type === typeFilter;
    const matchesPriority = priorityFilter === 'all' || aar.priority === priorityFilter;

    return matchesText && matchesType && matchesPriority;
  });

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900">
            DevOnboarder After Action Reports
          </h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        {/* Stats Overview */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">Total AARs</h3>
            <p className="text-3xl font-bold text-blue-600">{stats.total}</p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">This Month</h3>
            <p className="text-3xl font-bold text-green-600">{stats.recentCount}</p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">Top Type</h3>
            <p className="text-xl font-semibold text-purple-600">
              {Object.entries(stats.byType).sort(([,a], [,b]) => b - a)[0]?.[0] || 'N/A'}
            </p>
          </div>

          <div className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-medium text-gray-900">High Priority</h3>
            <p className="text-3xl font-bold text-red-600">
              {stats.byPriority.High || 0}
            </p>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white p-6 rounded-lg shadow mb-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700">Search</label>
              <input
                type="text"
                value={filter}
                onChange={(e) => setFilter(e.target.value)}
                placeholder="Search AARs..."
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Type</label>
              <select
                value={typeFilter}
                onChange={(e) => setTypeFilter(e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="all">All Types</option>
                <option value="Infrastructure">Infrastructure</option>
                <option value="CI">CI</option>
                <option value="Monitoring">Monitoring</option>
                <option value="Documentation">Documentation</option>
                <option value="Feature">Feature</option>
                <option value="Security">Security</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700">Priority</label>
              <select
                value={priorityFilter}
                onChange={(e) => setPriorityFilter(e.target.value)}
                className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="all">All Priorities</option>
                <option value="Critical">Critical</option>
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
              </select>
            </div>
          </div>
        </div>

        {/* AAR Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredAARs.map((aar, index) => (
            <AARCard key={index} aar={aar} />
          ))}
        </div>
      </main>
    </div>
  );
}

function AARCard({ aar }: { aar: AAR }) {
  const priorityColors = {
    Critical: 'bg-red-100 text-red-800',
    High: 'bg-orange-100 text-orange-800',
    Medium: 'bg-yellow-100 text-yellow-800',
    Low: 'bg-green-100 text-green-800'
  };

  const typeColors = {
    Infrastructure: 'bg-blue-100 text-blue-800',
    CI: 'bg-purple-100 text-purple-800',
    Monitoring: 'bg-pink-100 text-pink-800',
    Documentation: 'bg-gray-100 text-gray-800',
    Feature: 'bg-indigo-100 text-indigo-800',
    Security: 'bg-red-100 text-red-800'
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow hover:shadow-lg transition-shadow">
      <div className="flex justify-between items-start mb-4">
        <h3 className="text-lg font-semibold text-gray-900 line-clamp-2">
          {aar.title}
        </h3>
        <span className={`px-2 py-1 rounded-full text-xs font-medium ${priorityColors[aar.priority]}`}>
          {aar.priority}
        </span>
      </div>

      <p className="text-gray-600 text-sm mb-4 line-clamp-3">
        {aar.summary}
      </p>

      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-2">
          <span className={`px-2 py-1 rounded-full text-xs font-medium ${typeColors[aar.type]}`}>
            {aar.type}
          </span>
          <span className="text-sm text-gray-500">{aar.date}</span>
        </div>

        <div className="flex space-x-2">
          <a
            href={`/reports/${aar.filename}.html`}
            className="text-blue-600 hover:text-blue-800 text-sm font-medium"
          >
            View
          </a>
          <a
            href={`/reports/${aar.filename}.pdf`}
            className="text-green-600 hover:text-green-800 text-sm font-medium"
          >
            PDF
          </a>
          <a
            href={`/reports/${aar.filename}.md`}
            className="text-gray-600 hover:text-gray-800 text-sm font-medium"
          >
            Markdown
          </a>
        </div>
      </div>
    </div>
  );
}

// Static site generation
export const getStaticProps: GetStaticProps = async () => {
  // Read all AAR files and generate stats
  const aars = await generateAARIndex();
  const stats = calculateStats(aars);

  return {
    props: { aars, stats },
    revalidate: 3600 // Regenerate every hour
  };
};
```

## Component 4: API Integration Layer

### Express API for UI Integration

```typescript
// api/aar.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { exec } from 'child_process';
import { promises as fs } from 'fs';
import path from 'path';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method === 'POST') {
    try {
      const aarData = req.body;

      // Validate the data (already validated on frontend, but double-check)
      const validation = await validateAARData(aarData);
      if (!validation.valid) {
        return res.status(400).json({ error: 'Invalid AAR data', details: validation.errors });
      }

      // Generate filename
      const sanitizedTitle = aarData.title
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');
      const filename = `${aarData.date}_${sanitizedTitle}.aar.json`;

      // Write JSON file
      const jsonPath = path.join(process.cwd(), 'docs/AAR/data', filename);
      await fs.writeFile(jsonPath, JSON.stringify(aarData, null, 2));

      // Generate all formats using multi-format renderer
      const result = await new Promise((resolve, reject) => {
        exec(
          `node scripts/render_aar_multi.js ${jsonPath} docs/AAR/reports`,
          (error, stdout, stderr) => {
            if (error) {
              reject(error);
            } else {
              resolve({
                jsonFile: jsonPath,
                outputs: JSON.parse(stdout) // Multi-format renderer returns JSON
              });
            }
          }
        );
      });

      res.status(200).json({
        success: true,
        message: 'AAR generated successfully',
        ...result
      });

    } catch (error) {
      res.status(500).json({
        error: 'AAR generation failed',
        details: error.message
      });
    }
  } else {
    res.setHeader('Allow', ['POST']);
    res.status(405).end(`Method ${req.method} Not Allowed`);
  }
}

async function validateAARData(data: any): Promise<{ valid: boolean; errors?: string[] }> {
  // Use the existing schema validation from the Node.js renderer
  try {
    const { exec } = require('child_process');
    const tempFile = '/tmp/aar-validation.json';
    await fs.writeFile(tempFile, JSON.stringify(data, null, 2));

    return new Promise((resolve) => {
      exec(`npm run aar:validate ${tempFile}`, (error, stdout, stderr) => {
        if (error) {
          resolve({ valid: false, errors: [stderr] });
        } else {
          resolve({ valid: true });
        }
      });
    });
  } catch (error) {
    return { valid: false, errors: [error.message] };
  }
}
```

## Deployment Strategy

### Phase 2 Implementation Plan

1. **Week 1**: React form component with Zod validation
2. **Week 2**: Multi-format renderer (HTML, PDF, Email)
3. **Week 3**: Auto-linking system and GitHub integration
4. **Week 4**: Dashboard UI and GitHub Pages deployment

### Integration with Existing System

```bash
# Enhanced NPM scripts
{
  "scripts": {
    "aar:ui": "next dev",
    "aar:build-dashboard": "next build && next export",
    "aar:generate-multi": "node scripts/render_aar_multi.js",
    "aar:deploy-dashboard": "npm run aar:build-dashboard && gh-pages -d out"
  }
}
```

## Benefits of Phase 2

1. **Point-and-Click AAR Creation**: No technical knowledge required
2. **Multi-Format Output**: Stakeholders get PDFs, emails, and HTML
3. **Auto-Discovery**: Related PRs/issues linked automatically
4. **Searchable Archive**: Historical AARs easily discoverable
5. **Schema Enforcement Preserved**: UI generates same validated JSON

The UI layer becomes the user-friendly front-end while the bulletproof schema system remains the authoritative backend - best of both worlds!

Ready to implement any of these components?
