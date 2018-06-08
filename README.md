# What is this?
A tool for analysing the code-quality of any given github user

## Spies
Analyse and report on the Ruby projects belonging to a single, specified, GitHub user.  They can be configured to report on all Ruby projects or just those that were created within a specific period.  The Spy report returns an array of code quality scores.

## Missions
Analyse and report on the Ruby projects belonging to anyone within group of GitHub users.  They can be configured to report on all Ruby projects or just those that were created within a specific period.  The Mission report returns the mean and median code quality scores plus the number of repos analysed.

# How is code quality measured?
Using this https://github.com/whitesmith/rubycritic, CodeSpy only uses the overall score (out of 100) for each repo.

## Useage

### Start a mission

#### Using a CSV file of GitHub usernames

1. Expected CSV structure

```
"githubId", "timeToHire", "startDate"
<GitHubUsername>, <Int>, <Date>
<GitHubUsername>, <Int>, <Date>
<GitHubUsername>, <Int>, <Date>
# and so on...
```

2. Get the report

*N.B. The report will be written out to a text file*

```
# for all Ruby repos
mission = Mission.create_from_csv(file: my_csv.csv)
mission.report

# for Ruby repos within created within a 60 day period (startDate must also be set)
mission = Mission.create_from_csv(file: my_csv.csv, duration: 60)
mission.report
```

#### Using an array of GitHub users

1. Expected data structure for "target_hashes"

```
[
  {id: AwesomeGitHubUserID, start_date: 'yyyy-mm-dd'},
  {id: AnotherGitHubUserID, start_date: 'yyyy-mm-dd'}
  # and so on...
]
```

2. Get the report

*N.B. The report will be written out to a text file*

```
# for all Ruby repos
mission = Mission.new(targets: target_hashes)
mission.report

# for Ruby repos within created within a 60 day period (start_date must also be set)
mission = Mission.new(targets: target_hashes, duration: 60)
mission.report
```

## How to contribute

1. Get approved as a collaborator.
2. Have a look at the project board.
3. If there's no existing ticket for the work you want to do, please create one.
4. TDD some code and move your ticket accordingly.
5. Make a pull request.
