# Homebrew Formula para RSERVER
# Para usar: brew tap KelvinSilvaDev/rserver && brew install rserver

class Rserver < Formula
  desc "Remote Server Control - CLI multiplataforma para gerenciar serviços remotos"
  homepage "https://github.com/KelvinSilvaDev/rserver"
  url "https://github.com/KelvinSilvaDev/rserver/archive/v1.0.0.tar.gz"
  sha256 "CALCULE_O_HASH_AQUI"  # Use: shasum -a 256 arquivo.tar.gz
  license "Apache-2.0"
  head "https://github.com/KelvinSilvaDev/rserver.git", branch: "main"

  depends_on "python@3.9"

  def install
    # Criar diretório de instalação
    python3 = "python3.9"
    venv = virtualenv_create(libexec, python3)
    
    # Instalar dependências (se houver requirements.txt)
    if (buildpath/"cli/requirements.txt").exist?
      venv.pip_install resources
      venv.pip_install_and_link buildpath/"cli"
    else
      # Instalar diretamente
      system python3, "-m", "pip", "install", "--prefix=#{prefix}", "."
    end
    
    # Criar wrapper script
    bin.install "cli/rsctl_new.py" => "rserver"
    bin.env_script_all_files(libexec/"bin", PYTHONPATH: libexec/"lib/python3.9/site-packages")
  end

  test do
    system "#{bin}/rserver", "--version"
  end
end
