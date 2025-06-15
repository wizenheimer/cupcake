cask "cupcake" do
  version "1.0.3"
  sha256 "0626bdb6522f80fc45a72013a5b93a45441830ec2b08f11f58fa852da0e22d63"

  url "https://github.com/wizenheimer/cupcake/releases/download/v#{version}/cupcake.zip"
  name "Cupcake"
  desc "Dock cat animation app — unsigned"
  homepage "https://github.com/wizenheimer/cupcake"

  app "cupcake.app"

  caveats <<~EOS
    This app is not signed or notarized.
    To open it the first time:
      1. Right-click the app in Finder
      2. Click "Open"
      3. Confirm the dialog
  EOS
end
