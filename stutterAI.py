#!/usr/bin/env python3

from sys import stdin
import json
from pathlib import Path
import platform
import openai
from openai import error


MODEL = "gpt-4"

try:
    with open(Path("~/.stutterAI_secret.json").expanduser(), "r") as f:
        _API_KEY_ = json.load(f)["API_KEY"]
except FileNotFoundError or KeyError:
    raise SystemExit(215)

# Data Gathering
def gather_system_data():
    current_directory = Path.cwd()
    files_folders = [str(f) for f in current_directory.glob("*")]

    try:
        with open(Path("~/.bashrc").expanduser(), "r") as f:
            bashrc_contents = f.read()
    except FileNotFoundError:
        bashrc_contents = ""

    try:
        with open(Path("~/.bash_history").expanduser(), "r") as f:
            last_10_bash_history = f.readlines()[-10:]
    except FileNotFoundError:
        last_10_bash_history = ""

    data = {
        "operating_system": platform.system(),
        "current_directory_path": str(current_directory),
        "files_folders_in_current_directory": files_folders,
        "bashrc_contents": bashrc_contents,
        "bash_history_last_10_commands": last_10_bash_history,
    }

    return data


def ai_create_command(ai_prompt):
    openai.api_key = _API_KEY_
    response = openai.ChatCompletion.create(
        model=MODEL,
        messages=[
            {
                "role": "system",
                "content": "You are an AI that creates linux terminal commands based on prompts from users. Create a working command that follows best practice and official documentation that will accomplish the users prompt. Return command only and nothing else, unless the prompt is outside the scope of linux commands then return the exact statement 'Sorry I can't help with that.'",
            },
            {"role": "user", "content": json.dumps(ai_prompt)},
        ],
        temperature=0.6,
        max_tokens=250,
    )
    ai_command = response["choices"][0]["message"]["content"]
    return ai_command


def ai_fix_command(data):
    openai.api_key = _API_KEY_
    response = openai.ChatCompletion.create(
        model=MODEL,
        messages=[
            {
                "role": "system",
                "content": "You are an AI that fixes mistakes in terminal commands. Using the information provided, respond with a corrected version of the command. Prioritize barchrc alias and functions if it is a closer match than other commands. Return fixed command only and nothing else.",
            },
            {"role": "user", "content": json.dumps(data)},
        ],
        temperature=0.6,
        max_tokens=250,
    )
    ai_command = response["choices"][0]["message"]["content"]
    return ai_command


def ai_extract_path(command, error_message):
    openai.api_key = _API_KEY_
    response = openai.ChatCompletion.create(
        model=MODEL,
        messages=[
            {
                "role": "system",
                "content": "Determine if the command_error_message is related to an incorrect file path. If it is extract the file path from the provided command. Return only the extracted file path with no formatting or the number 0 if error is unrelated to file path.",
            },
            {
                "role": "user",
                "content": json.dumps({"command": command, "command_error_message": error_message}),
            },
        ],
        temperature=0.25,
        max_tokens=100,
    )
    if response["choices"][0]["message"]["content"] == "0":
        return False
    else:
        return response["choices"][0]["message"]["content"].replace('\\"', "").replace("\\", "").replace('"', "")


def ai_find_valid_path(path, cwd):
    # Validate if the path is a valid file or directory
    test_path = Path(path).resolve()
    if test_path.is_file() or test_path.is_dir():
        # If valid, return the valid path
        return test_path

    # If not valid, recursively remove elements from the path
    path_elements = len(path.split("/"))
    correct_number_of_elements = False
    valid_path = Path(path)
    i = 0
    while not (correct_number_of_elements and (valid_path.resolve().is_dir() or valid_path.resolve().is_file())):
        # Remove the last element in the path
        valid_path = valid_path.parent
        # In case we reach the root and it's not valid (highly unlikely)
        if str(valid_path.resolve()) == "/":
            return False

        if not (valid_path.resolve().is_dir() or valid_path.resolve().is_file()):
            continue
        file_data = {
            "operating_system": platform.system(),
            "broken_file_path": path.replace('"', ""),
            "list_of_valid_paths": "\n- ".join([str(f) for f in valid_path.glob("*")]),
        }
        if i < 1:
            ai_messages = [
                {
                    "role": "system",
                    "content": "Fix the user provided invalid path by replacing elements of the invalid path with extremely similar elements from one of the valid paths. Response must have the same amount of elements as the invalid path. Respond with the fixed path ONLY and nothing else. No formatting.",
                },
                {
                    "role": "user",
                    "content": f"Operating System: {file_data['operating_system']}\nInvalid PAth: {file_data['broken_file_path']}\nThese elements are valid: {'NONE' if str(valid_path) == '.' else str(valid_path)}\nList of Valid Paths:{file_data['list_of_valid_paths']}",
                },
            ]
        i += 1
        openai.api_key = _API_KEY_
        response = openai.ChatCompletion.create(model=MODEL, messages=ai_messages, temperature=0.25, max_tokens=512)
        valid_path = Path(response["choices"][0]["message"]["content"].replace('\\"', "").replace("\\", "").replace('"', ""))
        valid_path_elements = len(str(valid_path).split("/"))
        if path_elements != valid_path_elements:
            correct_number_of_elements = False
        else:
            correct_number_of_elements = True
        if i >= 1:
            ai_messages.append(
                {
                    "role": "assistant",
                    "content": response["choices"][0]["message"]["content"].replace('\\"', "").replace("\\", "").replace('"', ""),
                }
            )
            ai_messages.append(
                {
                    "role": "user",
                    "content": f"Previous response was still invalid. Try again using a different path.\nThese elements are now valid: {'NONE' if str(valid_path) == '.' else str(valid_path)}\nNew List of Valid Paths:{file_data['list_of_valid_paths']}",
                }
            )
        if i > 9:
            valid_path = False
            break

    return valid_path


def err(last_command, error_message):
    data = gather_system_data()
    data["command_error_message"] = error_message
    data["Command_to_fix"] = last_command
    path = ai_extract_path(last_command, error_message)
    if path:
        new_path = ai_find_valid_path(path, data["current_directory_path"])
        if new_path:
            change_path = {"Command_to_fix": data["Command_to_fix"], "replace_path_in_command_with_this_one": str(new_path)}
            ai_corrected_command = ai_fix_command(change_path)
            print(ai_corrected_command)
            raise SystemExit(0)
        else:
            print(f"Failed to repair file path in your command: {path}")
            raise SystemExit(1)
    else:
        ai_corrected_command = ai_fix_command(data)
        print(ai_corrected_command)
        raise SystemExit(0)


def uhm(question):
    data = gather_system_data()
    ai_prompt = {"user_prompt": question, "system_information_context": data}
    ai_created_command = ai_create_command(ai_prompt)
    if "sorry " in ai_created_command.lower():
        print(ai_created_command)
        raise SystemExit(1)
    print(ai_created_command)
    raise SystemExit(0)


if __name__ == "__main__":
    arguments = [i.strip() for i in str(stdin.readline(-1)).split("////")]
    if "uhm" in arguments:
        _, question = arguments
        try:
            uhm(question)
        except KeyboardInterrupt:
            raise SystemExit(200)
        except error.RateLimitError:
            raise SystemExit(210)
        except error.AuthenticationError:
            raise SystemExit(220)
    else:
        last_command, error_message = arguments
        try:
            err(last_command, error_message)
        except KeyboardInterrupt:
            raise SystemExit(200)
        except error.RateLimitError:
            raise SystemExit(210)
        except error.AuthenticationError:
            raise SystemExit(220)
