resource "aws_lb_target_group" "tg" {
    name     = "my-lb-tg"
    port     = 80
    protocol = "HTTP"
    vpc_id   = module.my_network.vpc_id
}

resource "aws_lb_target_group_attachment" "tg_attach" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = aws_instance.privateinstance.id
    port             = 3000
}