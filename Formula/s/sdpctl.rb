class Sdpctl < Formula
  desc "Official CLI tool for managing Appgate SDP Collectives"
  homepage "https://appgate.github.io/sdpctl/"
  url "https://github.com/appgate/sdpctl.git",
      using:    :git,
      tag:      "2023.11.07",
      revision: "4091dfc6ff22d06a3c7aef63192b8dbb94cffbeb"
  license "MIT"
  head "https://github.com/appgate/sdpctl.git", branch: "main"

  depends_on "go" => :build

  def install
    registry = "public.ecr.aws/appgate-sdp"
    ldflags = %W[
      -s -w
      -X github.com/appgate/sdpctl/cmd.version=#{version}
      -X github.com/appgate/sdpctl/cmd.commit=#{Utils.git_head}
      -X "github.com/appgate/sdpctl/cmd.buildDate=#{time}"
      -X github.com/appgate/sdpctl/pkg/factory.dockerRegistry=#{registry}
    ]

    system "go", "build", *std_go_args(ldflags: ldflags)

    generate_completions_from_executable(bin/"sdpctl", "completion", shells: [:bash, :zsh, :fish])
  end

  test do
    version_output = shell_output("#{bin}/sdpctl --version")
    assert_match "sdpctl version #{version}", version_output.split("\n")[0]

    profile_add = shell_output("#{bin}/sdpctl profile add test")
    expected = "Created profile test, run 'sdpctl profile list' to see all available profiles\n" \
               "run 'sdpctl profile set test' to select the new profile"
    assert_match expected, profile_add

    profile_set = shell_output("#{bin}/sdpctl profile set test")
    expected = "test is selected as current sdp profile\n" \
               "test is not configured yet, run 'sdpctl configure'"
    assert_match expected, profile_set

    configure = shell_output("#{bin}/sdpctl configure https://example.com:8443")
    expected = "Configuration updated successfully"
    assert_match expected, configure
  end
end
