cask "cupcake" do
  version "1.0.0"
  sha256 "cfe609ce54d3d0270cf639462bb7393b25ae95c572e7100baeea3f9c55aa7c52"

  url "https://github.com/wizenheimer/cupcake/releases/download/v\#{version}/cupcake.zip"
  name "Cupcake"
  desc "Dock cat animation app — unsigned"
  homepage "https://github.com/wizenheimer/cupcake"

  app "cupcake.app"

  caveats <<~EOS
    ⚠️ This app is not signed or notarized.
    To open it the first time:
      1. Right-click the app in Finder
      2. Click "Open"
      3. Confirm the dialog
  EOS
end
