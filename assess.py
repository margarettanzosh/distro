#!/usr/bin/env python3
"""
AP CSP Code Assessment Tool
Students run this to have an AI assess their understanding of their code.
"""

import os
import sys
import json
import datetime
from anthropic import Anthropic

# Color codes for terminal output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

def print_header(text):
    print(f"\n{Colors.BOLD}{Colors.CYAN}{text}{Colors.END}")

def print_ai(text):
    print(f"{Colors.BLUE}🤖 Claude: {Colors.END}{text}")

def print_error(text):
    print(f"{Colors.RED}Error: {Colors.END}{text}")

def print_success(text):
    print(f"{Colors.GREEN}✓ {Colors.END}{text}")

def read_code_file(filepath):
    """Read the code file and return its contents."""
    try:
        with open(filepath, 'r') as f:
            return f.read()
    except FileNotFoundError:
        print_error(f"File '{filepath}' not found.")
        return None
    except Exception as e:
        print_error(f"Error reading file: {e}")
        return None

def get_file_extension(filepath):
    """Determine if the file is Python or C."""
    return filepath.split('.')[-1].lower()

def create_assessment_prompt(code, language):
    """Create the initial prompt for Claude to assess the student."""
    return f"""You are assessing an AP Computer Science Principles student's understanding of their code. Your goal is to ask thoughtful questions that reveal whether they truly understand:

1. **How their code works** - Can they explain what specific parts do?
2. **Why they made specific choices** - Why use a for loop here? Why an array vs a list? Why this data structure?
3. **AP CSP concepts** - Understanding of sequencing, selection, iteration, abstraction, data representation
4. **Code design decisions** - Why they structured it this way, function choices, variable names

**The student's code ({language}):**
```{language}
{code}
```

**Your approach:**
- Ask 6-8 questions total
- Start with a warm, encouraging greeting
- Ask about specific parts of their code (reference line numbers or code snippets)
- Ask "why" and "how" questions, not just "what"
- Be conversational and supportive, like a helpful teacher
- If they struggle, guide them with follow-up questions
- Adapt based on their responses - dig deeper on interesting points
- Focus on THEIR understanding, not testing trivia

Start by greeting the student and asking your first question about their code."""

def conduct_assessment(code, language, student_name):
    """Run the interactive assessment session."""
    # Check for API key
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        print_error("ANTHROPIC_API_KEY environment variable not set.")
        print("Please set it with: export ANTHROPIC_API_KEY='your-key-here'")
        print("Get your API key at: https://console.anthropic.com/")
        return None
    
    try:
        client = Anthropic(api_key=api_key)
    except Exception as e:
        print_error(f"Failed to initialize Anthropic client: {e}")
        return None
    
    # Initialize conversation
    conversation_history = []
    system_prompt = create_assessment_prompt(code, language)
    
    print_header("🎓 AP CSP Code Assessment Started")
    print(f"Student: {student_name}")
    print(f"Time: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("\nYou'll have a conversation with Claude about your code.")
    print("Answer thoughtfully and explain your reasoning.")
    print("Type 'quit' or 'exit' to end early.\n")
    print("=" * 60)
    
    question_count = 0
    max_questions = 8
    
    # Initial message to start the assessment
    conversation_history.append({
        "role": "user",
        "content": f"Hi! My name is {student_name}. I'm ready to discuss my code."
    })
    
    while question_count < max_questions:
        try:
            # Get Claude's response
            response = client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=1000,
                system=system_prompt,
                messages=conversation_history
            )
            
            assistant_message = response.content[0].text
            conversation_history.append({
                "role": "assistant",
                "content": assistant_message
            })
            
            print_ai(assistant_message)
            
            # Check if Claude is wrapping up
            if any(phrase in assistant_message.lower() for phrase in 
                   ["great job", "nice work", "well done", "that's all", "thank you for", "good understanding"]) and question_count >= 5:
                print("\n" + "=" * 60)
                print_success("Assessment complete!")
                break
            
            # Get student response
            print(f"\n{Colors.GREEN}You: {Colors.END}", end='')
            student_response = input().strip()
            
            if student_response.lower() in ['quit', 'exit']:
                print("\nEnding assessment early...")
                break
            
            if not student_response:
                continue
            
            conversation_history.append({
                "role": "user",
                "content": student_response
            })
            
            question_count += 1
            
        except KeyboardInterrupt:
            print("\n\nAssessment interrupted by user.")
            break
        except Exception as e:
            print_error(f"Error during assessment: {e}")
            break
    
    return conversation_history

def save_transcript(conversation, student_name, code_file, code, language):
    """Save the assessment transcript to a JSON file."""
    timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"assessment_{student_name.replace(' ', '_')}_{timestamp}.json"
    
    transcript = {
        "student_name": student_name,
        "code_file": code_file,
        "language": language,
        "timestamp": datetime.datetime.now().isoformat(),
        "code": code,
        "conversation": conversation
    }
    
    try:
        with open(filename, 'w') as f:
            json.dump(transcript, f, indent=2)
        return filename
    except Exception as e:
        print_error(f"Failed to save transcript: {e}")
        return None

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 assess.py <code_file.py|code_file.c> [student_name]")
        print("\nExample:")
        print("  python3 assess.py mario.py \"John Smith\"")
        print("  python3 assess.py hello.c")
        sys.exit(1)
    
    code_file = sys.argv[1]
    student_name = sys.argv[2] if len(sys.argv) > 2 else input("Enter your name: ").strip()
    
    if not student_name:
        student_name = "Student"
    
    # Read the code
    code = read_code_file(code_file)
    if code is None:
        sys.exit(1)
    
    # Determine language
    ext = get_file_extension(code_file)
    if ext == 'py':
        language = 'python'
    elif ext == 'c':
        language = 'c'
    else:
        print_error(f"Unsupported file type: .{ext}")
        print("Only Python (.py) and C (.c) files are supported.")
        sys.exit(1)
    
    # Run the assessment
    conversation = conduct_assessment(code, language, student_name)
    
    if conversation is None:
        sys.exit(1)
    
    # Save transcript
    print("\n" + "=" * 60)
    transcript_file = save_transcript(conversation, student_name, code_file, code, language)
    
    if transcript_file:
        print_success(f"Transcript saved to: {transcript_file}")
        print(f"\n📤 Submit this file to your teacher: {Colors.BOLD}{transcript_file}{Colors.END}")
    else:
        print_error("Failed to save transcript. Please try again.")
        sys.exit(1)

if __name__ == "__main__":
    main()
