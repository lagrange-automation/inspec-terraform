require 'open3'
require 'json'

# Interact with Terraform outputs as InSpec resources
class TerraformOutputs < Inspec.resource(1)
  name 'terraform_outputs'

  # @!attribute [r] dir
  #   @return [String] the directory where the Terraform outputs will be looked up
  attr_reader :dir

  # @!attribute [r] mod
  #   @return [String] An optional terraform module to look up outputs, instead of
  #                    of the root module.
  attr_reader :mod

  # @!attribute [r] outputs
  #   @return [String] The a Hash containing all Terraform outputs.
  attr_reader :outputs

  def initialize(dir: Dir.getwd(), mod: nil)
    @dir = dir
    @mod = mod
    read_outputs()
  end

  def exist?
    !@outputs.nil?
  end

  def method_missing(m, *args)
    key = m.to_s
    if exist? && @outputs.key?(key)
      @outputs[key]["value"]
    else
      nil
    end
  end

  def to_s
    "Terraform outputs (#{@dir})"
  end

  private

  def read_outputs
    cmd = "terraform output -json"
    if @mod
      cmd << " -module #{@mod}"
    end

    out, _err, status = Open3.capture3(cmd, chdir: @dir)

    if status.exitstatus == 0
      @outputs = JSON.load(out)
    end
  end
end
