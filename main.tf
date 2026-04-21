provider "aws" {
    region = "us-east-2"
}

resource "aws_key_pair" "deployer"{
    key_name = "ollama-key"
    public_key = file("~/.ssh/ollama_aws.pub")
}

resource "aws_security_group" "ollama_sg" {
  name        = "ollama_sg"
  description = "Allow SSH inbound traffic"

  # Inbound rules (Who can connect to the server)
  ingress {
    from_port   = 22            
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Outbound rules (The server is allowed to access the internet to download models)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"           # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# data "aws_ami" "deep_learning" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = [""]
#   }

#     filter {
#     name   = "architecture"
#     values = ["x86_64"]
#   }
# }

resource "aws_instance" "ollama_server" {
  ami           = "ami-0c6b386534e3e1534"
  instance_type = "g6.xlarge" 
  key_name      = aws_key_pair.deployer.key_name

  # Attach the firewall we made in Step 3
  vpc_security_group_ids = [aws_security_group.ollama_sg.id]

    instance_market_options {
    market_type = "spot"
    spot_options {
      # "one-time" means if AWS interrupts and takes the server back, 
      # it won't automatically try to buy a new one to replace it.
      spot_instance_type = "one-time" 
    }
  }
  # ----------------------------------------

  # Give the server a 100GB hard drive (AI models are large)
  root_block_device {
    volume_size = 100
    volume_type = "gp3"
  }

  # The Startup Script
  user_data = <<-EOF
    #!/bin/bash
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.local/bin/env
    uv venv --python 3.12 --seed --managed-python
    source .venv/bin/activate
    uv pip install vllm
    vllm serve "Qwen/Qwen3.5-9B"
  EOF



  tags = {
    Name = "Ollama-GPU-Server"
  }
}

output "connection_command" {
  value = "ssh -i ~/.ssh/ollama_aws -N -L 8000:localhost:8000 ubuntu@${aws_instance.ollama_server.public_ip}"
}

output "connection" {
  value = "ssh -i ~/.ssh/ollama_aws ubuntu@${aws_instance.ollama_server.public_ip}"
}