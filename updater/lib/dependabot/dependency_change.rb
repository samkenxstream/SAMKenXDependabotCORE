# frozen_string_literal: true

# This class describes a change to the project's Dependencies which has been
# determined by a Dependabot operation.
#
# It includes a list of changed Dependabot::Dependency objects, an array of
# Dependabot::DependencyFile objects which contain the changes to be applied
# along with any Dependabot::GroupRule that was used to generate the change.
#
# This class provides methods for presenting the change set which can be used
# by adapters to create a Pull Request, apply the changes on disk, etc.
module Dependabot
  class DependencyChange
    attr_reader :job, :dependencies, :updated_dependency_files

    def initialize(job:, dependencies:, updated_dependency_files:, group_rule: nil)
      @job = job
      @dependencies = dependencies
      @updated_dependency_files = updated_dependency_files
      @group_rule = group_rule
    end

    def pr_message
      return @pr_message if defined?(@pr_message)

      @pr_message = Dependabot::PullRequestCreator::MessageBuilder.new(
        source: job.source,
        dependencies: dependencies,
        files: updated_dependency_files,
        credentials: job.credentials,
        commit_message_options: job.commit_message_options
      ).message
    end

    def humanized
      dependencies.map do |dependency|
        "#{dependency.name} ( from #{dependency.previous_version} to #{dependency.version} )"
      end.join(", ")
    end

    def updated_dependency_files_hash
      updated_dependency_files.map(&:to_h)
    end

    # FIXME: This is a placeholder for using a concrete GroupRule object to create
    # as grouped rule hash to pass to the Dependabot API client. For now, we just
    # use a flag on whether a rule has been assigned to the change.
    def grouped_update?
      !!@group_rule
    end
  end
end
