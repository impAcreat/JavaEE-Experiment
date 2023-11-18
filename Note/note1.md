# 服务器配置：JavaEE实验

## 服务器功能分配：

* 一台作为管理机：(**Ubuntu-cn-east-3-LxM8**)

  * 公网ip：

    ```
    60.204.231.172
    ```

  * 内网ip：

    ```
    192.168.12.219
    ```

* 一台作为工作机：(**Ubuntu-cn-east-3-0N34**)

  * 公网ip：

  ```
  	123.60.49.136
  ```

  * 内网ip：

  ```
  	192.168.1.160
  ```

* 一台作为测试机：(**Ubuntu-cn-east-3-3677**): 安装java和jmit:

  * 公网ip：

    ```
    60.204.250.242
    ```

  * 内网ip：

    ```
    192.168.13.232
    ```

## 配置多台服务器：

* 通过`ssh`连接：

  ```cmd
  ssh root@ipAddress
  ```

* 安装`Docker`：（工作机 & 服务机）

  * reference：https://docs.docker.com/engine/install/ubuntu/

  * 安装成功：

    ```cmd
    docker ps
    ```

  * 创建swarm集群：

    * 该命令使本机为管理机，并产生代码，在其它服务器上运行代码变为工作机

    ```cmd
    docker swarm init
    //产生代码：
    docker swam join --token ...
    ```

  * *操作一般都在管理机上执行*

  * 查看所有服务器：

    ```cmd
    docker node ls
    ```

  * 在docker中建立`overlay`网络，实现对docker中服务器的连接：

    ```cmd
    docker network create -d overlay my-net
    ```

    

## 安装MySQL

* 参考ooad readme: [文件 - OOMALL - Repo (huaweicloud.com)](https://devcloud.cn-north-4.huaweicloud.com/codehub/project/36dd051d2c9646e8bb61daaf3f330f23/codehub/2346649/home?ref=master&filePath=README.md&isFile=true)

* **该部分操作在管理机上进行，将mysql安装到工作机上**

* 为目标服务器定义**label**：

  * 原因：MySQL一般只部署在一个服务器（工作机）上
  * 方便docker swarm在创建Service时，将Service部署在目标服务器上
  * 定义label：

  ```cmd
  docker node update --label-add server=mysql <结点码：即工作机服务器编号>
  ```

  * 查看label：

  ```cmd
  docker node inspect <节点码>
  ```

* 创建Mysql：

  * 使用docker命令：在整个集群中**建立服务**mysql
  * 其中的constraint限制部署：仅在label符合要求的机器上建立
  * 设置密码为：lalalagroup

```cmd
docker service create --name mysql --constraint node.labels.server==mysql  --network my-net -e MYSQL_ROOT_PASSWORD=lalalagroup -d mysql:latest
```

* 查看：

```cmd
docker service ls
//详细：
docker service inspect mysql
```

## 运行sql脚本

* 该部分在**工作机**上完成

* 查看服务运行情况：

```cmd
docker ps
```

* 在该服务器上进行上次实验的内容

  * 将javaee包传到服务器上，cd到目标文件夹（git pull也行）
  * 进入容器终端

  ```cmd
  docker exec -it [CONTAINER ID] bash
  ```

  * 运行mysql（进入mysql终端）：

  ```cmd
   mysql -uroot -p
  
  ```

  * `source`命令执行sql文件

  * `use`命令切换数据库

## 部署应用

* 该操作在**管理机**上运行
* 环境：
  * jdk：17
  * maven：3.9.5
* 在 productdemoaop中的pom.xml 和 Dockerfile已经写好了命令：
  * 由于没有数据库，skip测试过程

```cmd
mvn pre-integration-test -Dmaven.test.skip=true
```

* 创建服务：将生成的镜像部署在swarm集群中：

```cmd
docker service create --name product --network my-net -p 8080:8080 -d xmu-javaee/productdemoaop:0.0.1-SNAPSHOT
```

* 部署完成后，服务部署在节点上，接下来测试服务器提供的服务：使用JMeter

****

## JMeter

* 测试命令：
  * -n：后台运行（非GUI模式运行）
  * -t ：测试内容（.jmx文件）
  * -l ：结果存入日志（.jtl文件）

```cmd
jmeter -n -t <method.jmx> -l <res.jtl>

jmeter -n -t jmx/ReadProduct.jmx -l jtl/FNH/1800-10.jtl
```

* 生成统计报表：

```cmd
jmeter -g <res.jtl> -o result/

jmeter -g jtl/FNH/1800-10.jtl -o result/FNH/1800-10
```

* 复制：

```cmd
scp -r root@<ip address>:/<dir>/* <target dir>/
```

