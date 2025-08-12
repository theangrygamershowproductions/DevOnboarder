import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { execFile } from 'child_process';
import { promisify } from 'util';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const execFileAsync = promisify(execFile);

interface GitHubIssueData {
  title: string;
  body: string;
  number: number;
}

interface ParsedAAR {
  schema_version: string;
  title: string;
  date: string;
  type: string;
  priority: string;
  executive_summary: {
    problem: string;
    solution: string;
    outcome: string;
  };
  phases: Array<{
    name: string;
    duration: string;
    status: string;
    description: string;
  }>;
  outcomes: {
    success_metrics: string[];
    challenges_overcome: string[];
  };
  follow_up?: {
    action_items: Array<{
      task: string;
      owner: string;
      due_date: string;
      status: string;
    }>;
  };
  lessons_learned?: string[];
}

// Parse GitHub issue form data into AAR JSON
function parseIssueToAAR(issueData: GitHubIssueData): ParsedAAR {
  const { title, body } = issueData;

  // Extract form fields using regex patterns
  const extractField = (fieldName: string): string => {
    const pattern = new RegExp(`### ${fieldName}\\s*\\n\\s*([\\s\\S]*?)(?=\\n### |\\n\\n### |$)`, 'i');
    const match = body.match(pattern);
    return match ? match[1].trim() : '';
  };

  const extractListField = (fieldName: string): string[] => {
    const content = extractField(fieldName);
    return content
      .split('\n')
      .map(line => line.trim())
      .filter(line => line && !line.startsWith('_No response_'))
      .map(line => line.replace(/^[-*]\s*/, ''));
  };

  // Parse phases (format: "Phase Name | Duration | Status | Description")
  const parsePhases = (content: string): Array<{ name: string; duration: string; status: string; description: string }> => {
    const lines = content.split('\n').filter(line => line.trim() && !line.includes('_No response_'));
    return lines.map(line => {
      const parts = line.split('|').map(p => p.trim());
      return {
        name: parts[0] || 'Unnamed Phase',
        duration: parts[1] || '1 week',
        status: parts[2] || 'Completed',
        description: parts[3] || 'Phase description not provided'
      };
    });
  };

  // Parse action items (format: "Task | Owner | Due Date | Status")
  const parseActionItems = (content: string): Array<{ task: string; owner: string; due_date: string; status: string }> => {
    const lines = content.split('\n').filter(line => line.trim() && !line.includes('_No response_'));
    return lines.map(line => {
      const parts = line.split('|').map(p => p.trim());
      return {
        task: parts[0] || 'Unnamed task',
        owner: parts[1] || 'Unassigned',
        due_date: parts[2] || new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        status: parts[3] || 'Not Started'
      };
    });
  };

  // Extract title from issue title (remove "AAR:" prefix if present)
  const aarTitle = title.replace(/^\[?AAR\]?:?\s*/i, '').trim();

  // Build AAR object
  const aar: ParsedAAR = {
    schema_version: "1.0.0",
    title: aarTitle || extractField('Initiative Title') || 'Untitled Initiative',
    date: extractField('Completion Date') || new Date().toISOString().split('T')[0],
    type: extractField('Initiative Type') || 'Infrastructure',
    priority: extractField('Priority Level') || 'Medium',
    executive_summary: {
      problem: extractField('Problem Statement') || 'Problem statement not provided',
      solution: extractField('Solution Approach') || 'Solution approach not provided',
      outcome: extractField('Final Outcome') || 'Outcome not provided'
    },
    phases: parsePhases(extractField('Project Phases')),
    outcomes: {
      success_metrics: extractListField('Success Metrics'),
      challenges_overcome: extractListField('Challenges Overcome')
    }
  };

  // Add optional sections if they have content
  const followUpContent = extractField('Follow-up Actions');
  if (followUpContent && !followUpContent.includes('_No response_')) {
    aar.follow_up = {
      action_items: parseActionItems(followUpContent)
    };
  }

  const lessonsLearned = extractListField('Lessons Learned');
  if (lessonsLearned.length > 0) {
    aar.lessons_learned = lessonsLearned;
  }

  return aar;
}

// Generate filename from AAR data
function generateFilename(aar: ParsedAAR): string {
  const date = aar.date;
  const title = aar.title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
  return `${date}_${title}.aar.json`;
}

// Main processing function
async function processIssueAAR(issueNumber: string): Promise<void> {
  try {
    console.log(`🔄 Processing issue #${issueNumber} for AAR generation...`);

    // Get issue data using GitHub CLI
    const { stdout } = await execFileAsync('gh', [
      'issue', 'view', issueNumber,
      '--json', 'title,body,number'
    ]);

    const issueData: GitHubIssueData = JSON.parse(stdout);
    console.log(`📋 Issue title: ${issueData.title}`);

    // Parse issue into AAR format
    const aar = parseIssueToAAR(issueData);
    console.log(`📝 Parsed AAR: ${aar.title}`);

    // Ensure directories exist
    const dataDir = path.join(__dirname, '../docs/AAR/data');
    const reportsDir = path.join(__dirname, '../docs/AAR/reports');

    await fs.mkdir(dataDir, { recursive: true });
    await fs.mkdir(reportsDir, { recursive: true });

    // Write AAR JSON file
    const filename = generateFilename(aar);
    const aarPath = path.join(dataDir, filename);
    await fs.writeFile(aarPath, JSON.stringify(aar, null, 2));
    console.log(`💾 Saved AAR data: ${filename}`);

    // Render AAR using existing system
    try {
      console.log('🎨 Rendering AAR report...');
      const { stdout: renderOutput } = await execFileAsync('npm', [
        'run', 'aar:render', aarPath, reportsDir
      ], {
        cwd: path.join(__dirname, '..')
      });
      console.log('✅ AAR rendered successfully');
      console.log(renderOutput);
    } catch (renderError) {
      console.error('⚠️ Render failed:', renderError);
      throw renderError;
    }

    // Validate the generated AAR
    try {
      console.log('🔍 Validating AAR...');
      await execFileAsync('npm', ['run', 'aar:validate', aarPath], {
        cwd: path.join(__dirname, '..')
      });
      console.log('✅ AAR validation passed');
    } catch (validationError) {
      console.error('❌ AAR validation failed:', validationError);
      throw validationError;
    }

    console.log(`🎉 Successfully processed issue #${issueNumber} into AAR: ${filename}`);

  } catch (error) {
    console.error(`💥 Failed to process issue #${issueNumber}:`, error);
    process.exit(1);
  }
}

// CLI interface
const issueNumber = process.argv[2];
if (!issueNumber) {
  console.error('Usage: node issue_to_aar_json.js <issue_number>');
  console.error('Example: node issue_to_aar_json.js 123');
  process.exit(1);
}

// Process the issue
processIssueAAR(issueNumber);
