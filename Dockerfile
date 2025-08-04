FROM registry-dev.vestack.sbuxcf.net/bci/golang:1.17.2-alpine.base

WORKDIR /app

# 复制编译好的二进制
COPY crane-autoscaling-example /app/

# 设置执行权限
RUN chmod +x /app/crane-autoscaling-example

# 运行应用
CMD ["/app/crane-autoscaling-example"]