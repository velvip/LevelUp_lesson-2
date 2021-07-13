resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey" # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

data "aws_ami" "rsyslog" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "rsyslog" {
  ami                    = data.aws_ami.rsyslog.id
  key_name               = aws_key_pair.kp.key_name
  instance_type          = "t2.micro"
  private_ip             = "192.168.0.240"
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  tags = {
    Name = "VM_RSYSLOG"
  }
  provisioner "remote-exec" {
    inline = [ #install Rsyslog server and allow port in ufw
      "sudo ufw allow 514/udp",
      "sudo ufw allow 514/tcp",
      "sudo apt-get install rsyslog -y",
      "sudo systemctl enable rsyslog",
    ]
  }
  provisioner "file" { #copy conf file for Rsyslog server
    source      = "rsyslog.conf"
    destination = "./rsyslog.conf"
  }
  provisioner "remote-exec" {
    inline = [ #copy file to rsyslog conf path and restart rsyslog
      "sudo rm /etc/rsyslog.conf",
      "sudo mv ./rsyslog.conf /etc/rsyslog.conf",
      "sudo systemctl restart rsyslog",
    ]
  }
  connection { #Connect to VM
    host        = aws_instance.rsyslog.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.pk.private_key_pem
  }
}

data "aws_ami" "log" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "log" {
  ami                    = data.aws_ami.log.id
  key_name               = aws_key_pair.kp.key_name
  instance_type          = "t2.micro"
  private_ip             = "192.168.0.239"
  subnet_id              = aws_subnet.subnet_public.id
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]
  tags = {
    Name = "VM_log"
  }
  provisioner "file" { #copy script for loging time to VM
    source      = "log.sh"
    destination = "/tmp/log.sh"
  }
  provisioner "file" { #copy script for cron to VM
    source      = "script_cron.sh"
    destination = "/tmp/script_cron.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/script_cron.sh",
      "sudo chmod +x /tmp/log.sh",
      "sudo bash /tmp/script_cron.sh", #run script to modify cron
      "sudo apt-get -y update",
      "sudo apt-get install rsyslog -y", #install Rsyslog
      "sudo systemctl enable rsyslog",
    ]
  }
  provisioner "file" { #copy conf file vm
    source      = "time.conf"
    destination = "./time.conf"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mv ./time.conf /etc/rsyslog.d/time.conf",#copy conf file to rsyslog client
      "sudo systemctl restart rsyslog",
    ]
  }
  connection { #Connect to VM
    host        = aws_instance.log.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.pk.private_key_pem
  }
}