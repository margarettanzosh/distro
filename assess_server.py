#!/usr/bin/env python3
"""
AP CSP Code Assessment Tool (Server Client Version)
Students run this to have an AI assess their understanding of their code.
Connects to teacher's assessment server instead of using API key directly.
"""

import sys
import json
import datetime
import requests

# INSTRUCTOR: Update this with your server's IP address BEFORE distributing to students
# When running server.py, it will display your network IP (e.g., http://100.103.88.201:5001)
# Replace the URL below with that address
SERVER_URL = "http://100.103.88.201:5001"

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

def check_server():
    """Check if the server is accessible."""
    try:
        response = requests.get(f"{SERVER_URL}/health", timeout=5)
        if response.status_code == 200:
            return True
        return False
    except requests.exceptions.RequestException:
        return False

def send_assessment_request(code, language, student_name, messages):
    """Send request to assessment server."""
    try:
        response = requests.post(
            f"{SERVER_URL}/assess",
            json={
                "student_name": student_name,
                "code": code,
                "language": language,
                "messages": messages
            },
            timeout=30
        )
        
        if response.status_code == 200:
            return response.json()["response"], None
        elif response.status_code == 429:
            # Rate limit exceeded
            error = response.json().get("error", "Rate limit exceeded")
            return None, error
        else:
            error = response.json().get("error", "Server error")
            return None, error
            
    except requests.exceptions.Timeout:
        return None, "Request timed out. Server may be busy."
    except requests.exceptions.RequestException as e:
        return None, f"Connection error: {e}"

def conduct_assessment(code, language, student_name, code_file):
    """Run the interactive assessment session."""
    # Check server connectivity
    print("Connecting to assessment server...")
    if not check_server():
        print_error(f"Cannot connect to server at {SERVER_URL}")
        print("Make sure:")
        print("  1. Your teacher's server is running")
        print("  2. You're on the same network")
        print(f"  3. SERVER_URL is correct: {SERVER_URL}")
        return None
    
    print_success("Connected to server!")
    
    # Initialize conversation
    conversation_history = []
    
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
            # Get Claude's response from server
            assistant_message, error = send_assessment_request(
                code, language, student_name, conversation_history
            )
            
            if error:
                print_error(error)
                if "limit" in error.lower():
                    print("\nYou've reached your assessment limit.")
                    print("Contact your teacher if you need more assessments.")
                break
            
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
        print("Usage: python3 assess_server.py <code_file.py|code_file.c> [student_name]")
        print("\nExample:")
        print("  python3 assess_server.py mario.py \"John Smith\"")
        print("  python3 assess_server.py hello.c")
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
    conversation = conduct_assessment(code, language, student_name, code_file)
    
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
