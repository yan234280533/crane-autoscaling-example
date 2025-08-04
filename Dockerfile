FROM alpine:3.18

WORKDIR /app

# 复制编译好的二进制
COPY crane-autoscaling-example /app/

# 设置执行权限
RUN chmod +x /app/crane-autoscaling-example

# 运行应用
CMD ["/app/crane-autoscaling-example"]