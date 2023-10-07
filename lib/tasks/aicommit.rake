#!/usr/bin/env ruby
require 'colorize'


# Define a new namespace for git-related tasks.
namespace :git do

  # Description for the rake task.
  desc "Generate AI-based commit messages"

  # Define the 'commit' task within the 'git' namespace.
  task commit: :environment do

    # Check the current git status.
    status = `git status --porcelain`.chomp

    # Exit if there are no changes detected.
    if status.empty?
      puts "No changes detected. Please make changes before committing.".red
      exit
    else
      # Stage all changes for commit.
      puts "Detected new changes. Adding changes...".yellow
      system("git add .")
    end

    # Display a welcome message.
    puts "▲ ".white + "Welcome to AICommit!".green

    # Define the maximum tokens for the OpenAI prompt.
    MAX_TOKENS_FOR_PROMPT = 3897  # Total tokens minus some reserved for the completion.

    # Fetch the current git diff for staged changes.
    diff = `git diff --cached`.chomp

    # Truncate the diff if it's too long for better readability.
    if diff.length > 2000
      diff_start = diff[0..999]
      diff_end = diff[-999..-1]
      diff = "#{diff_start}\n... (truncated) ...\n#{diff_end}"
    end

    # Pre-process the diff to capture main actions (e.g., file additions or deletions).
    actions = []
    diff_lines = diff.split("\n")
    diff_lines.each do |line|
      if line.start_with?("create mode")
        actions << "Added #{line.split.last}"
      elsif line.start_with?("delete mode")
        actions << "Removed #{line.split.last}"
      end
    end

    # Summarize the actions into a single string.
    summary = actions.join(" and ")

    # Construct the OpenAI prompt using the summary.
    prompt = "Based on the code changes, provide a concise commit message summarizing the main actions: #{summary}"

    # Ensure the prompt doesn't exceed the model's token limit.
    if prompt.length > MAX_TOKENS_FOR_PROMPT
      prompt = "#{prompt[0..MAX_TOKENS_FOR_PROMPT]}... (truncated)"
    end

    # Get the AI response using the constructed prompt.
    response = OpenaiService.generate_response(
      prompt,
      0.5,
      "gpt-3.5-turbo-instruct",
      100
    )

    # Handle potential errors from the OpenAI response.
    if response.is_a?(Hash) && response.key?("error")
      puts "Error from OpenAI: #{response["error"]["message"]}".red
      exit
    end

    # Extract the AI-generated commit message.
    response_text = response.dig("choices", 0, "text")

    # Validate the AI response.
    if response_text.nil? || response_text.strip.empty?
      puts "Failed to generate a commit message. Please try again.".red
      exit
    end

    # Clean up the AI response for use as a commit message.
    cleaned_up_response = response_text.strip

    # Ask the user for confirmation to use the AI-generated commit message.
    puts "\nWould you like to use this commit message? (Y/n) "
    confirmation_message = STDIN.gets.chomp

    # If the user confirms, execute the git commit with the AI-generated message.
    if confirmation_message.downcase != "n"
      system("git commit -m 'Commit message: #{cleaned_up_response}'")
    end

  end
end
