
<div align="center">
  <div>
    <img src="/app/assets/images/AI_commit.png" alt="AI Commit" width="1270" height="auto">
    <h1 align="center">AI Commits</h1>
  </div>
	<p><b>AI</b> add git changes and writes your git commit messages for you. Never write a commit message again.</p>
</div>

---

### Setup
#### What you need to start using AI Commits:

**1. OpenAI gem:**
* add gem [ruby-openai](https://github.com/alexrudall/ruby-openai) to your Gemfile and run `bundle install` to install the gem.

**2. OpenAI API Key:**
* Grab your API key from [OpenAI](https://platform.openai.com/account/api-keys).

**3. Rails credentials:**
Add your keys to Rails credentials. To do this, run the following command in your terminal:
```shell
EDITOR="code --wait" rails credentials:edit
```
This opens up the credentials.yml file in VS Code. Once credentials file is open add the following:
```yaml
openai:
  access_token: sk-youropenaicredentialsapikey
```
After you added credentials, save and close the file.

**4. colorize gem -  _optional_**
* Add gem [colorize](https://github.com/fazibear/colorize) to your Gemfile and run `bundle install` to install the gem. This gem is used to colorize the output of the rake task.

* Run `gem install colorize` to install the gem.
* We ensure the gem is working by adding `require 'colorize'` to our Script.


You can remove this gem if you don't want to colorize the output. If you remove the gem, you will also need to remove the `require 'colorize'` line from the [rake task]((/lib/tasks/aicommit.rake)) file.



**5. Openai Service:**
* Openai service file is located in [app/services/openai_service.rb](/app/services/openai_service.rb)` and contains the following:

```ruby
module OpenaiService
  def self.generate_response(prompt, temperature, model_engine, max_tokens, freq_pen=0.0, pres_pen=0.0)
    access_token = Rails.application.credentials.dig(:openai, :access_token)
    client = OpenAI::Client.new(access_token: access_token)

    response = client.completions(
      parameters: {
        prompt: prompt,
        temperature: temperature,
        model: model_engine,
        max_tokens: max_tokens,
        frequency_penalty: freq_pen,
        presence_penalty: pres_pen
      }
    )
    response  # Return the entire response, not just the text
  end
end
```
* This service is responsible for making the API call to OpenAI and returning the generated text. You can change the parameters to your liking. For more information on the parameters, check out the [OpenAI API Docs](https://beta.openai.com/docs/api-reference/completions/create).

**6. aicommit rake task:**
* This file is located in [lib/tasks/aicommit.rake](/lib/tasks/aicommit.rake) and contains all the logic for generating the commit message.
Notice that I'm using the latest OpenAI model engine **gpt-3.5-turbo-instruct**. You would need to have a "Plus" plan.

KI've added some comments to the code to help you understand what's going on. Feel free to change the code to your liking. For more information on the parameters, check out the [OpenAI API Docs](https://beta.openai.com/docs/api-reference/completions/create).

**⚠️ Warning:**
- OpenAI will throw a deprecation error `{"warning"=>"This model version is deprecated. Migrate before January 4, 2024 to avoid disruption of service. "model"=>"text-davinci-003"...} Failed to generate a commit message. Please try again.` [learn more](https://platform.openai.com/docs/deprecations).
If you are using an older model engine, you can change the model engine. For more information on the model engines, check out the [OpenAI Models docs](https://platform.openai.com/docs/models/models).

**7. Using the rake task:**
* To use the rake task, run the following command in your terminal:
```shell
rake git:commit
```
* This will run the [rake task]((/lib/tasks/aicommit.rake)) and check if there are any changes in your git repo. If there are changes, it will add the changes and generate a commit message for you. You will be prompted to confirm the commit message before it is committed. Check image above for example 👆🏼

### Future Plans
- [ ] More specific commit messages, we might need to further refine the logic that extracts the summary of changes from the git diff. The current logic only looks for "create mode" and "delete mode" to determine added or removed files, but it doesn't capture content-based changes within files.

- [ ] We might consider extracting method or class names that have been added or removed. I think it would require more parsing of the git diff output, possibly using regular expressions or even a parser for the specific programming language you're working with.

- [ ] Add some Rails minitest tests to make sure the rake task is working as expected.

### Contributing
- This is an early version and idea of the repo, so there are probably [some bugs and things that need to be improved](https://github.com/AhmedNadar/ai_commit/issues). If you have any suggestions or ideas, please feel free to open an issue or submit a [pull request](https://github.com/AhmedNadar/ai_commit/pulls).

- Bug reports and pull requests are welcome on GitHub at https://github.com/ahmednadar/ai_commit. This project is intended to be a safe, welcoming space for collaboration.


### License
The repo is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### Maintainer
- **Ahmed Nadar**: [@ahmednadar](https://github.com/ahmednadar) [<img src="https://img.shields.io/twitter/follow/ahmednadar?style=flat&label=ahmednadar&logo=twitter&color=0bf&logoColor=fff" align="center">](https://twitter.com/ahmednadar)
