cask "cupcake" do
  version "1.0.1"
  sha256 "90ff13cea43063503c231b981b9abebe3728a29beb9821bd601a5b361a00686f"

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