#----------------如何把iOS Pod 库打包成framwork-------
#1.确保目录名、podspec的名字保持一致，
#  例如在AFNetworking目录放你想要打包的AFNetworking.podspec
#2.确保--spec-sources参数后面自己公司私库的repo放在前面
#3.确保自己的私库可以独立编译通过，不能有循环依赖(Xcode中可以通过设置编译通过，但是打包)
#4.把脚本放在跟 AFNetworking.podspec 一个目录下，直接执行./iOS_pod_framework.sh就可以打包成功
#--------------pod package 参数说明-------------------
#--force:强制覆盖之前已经生成过的二进制库 

#--embedded 生成静态.framework 

#--library 生成静态.a 

#--dynamic 生成动态.framework 

#--bundle-identifier  动态.framework是需要签名的，所以只有生成动态库的时候需要这个BundleId 

#--exclude-deps 不包含依赖的符号表，生成动态库的时候不能包含这个命令，动态库一定需要包含依赖的符号表。 

#--configuration 表示生成的库是debug还是release，默认是release。--configuration=Debug 

#--no-mangle 表示不使用name mangling技术，
#            pod package默认是使用这个技术的。
#            我们能在用pod package生成二进制库的时候会看到终端有输出Mangling symbols和
#            Building mangled framework。表示使用了这个技术
#            如果你的pod库没有其他依赖的话，那么不使用这个命令也不会报错。但是如果有其他依赖，
#            不使用--no-mangle这个命令的话，那么你在工程里使用生成的二进制库的时候就会报错：
#            Undefined symbols for architecture x86_64。

#--subspecs 如果你的pod库有subspec，那么加上这个命名表示只给某个或几个subspec生成二进制库，
#           --subspecs=subspec1,subspec2。生成的库的名字就是你podspec的名字，
#           如果你想生成的库的名字跟subspec的名字一样，那么就需要修改podspec的名字。 

#--spec-sources 这个脚本就是批量生成subspec的二进制库，
#               每一个subspec的库名就是podspecName+subspecName。
#               一些依赖的source，如果你有依赖是来自于私有库的，那就需要加上那个私有库的source，
#               默认是cocoapods的Specs仓库。--spec-sources=private,https://github.com/CocoaPods/Specs.git。
#------------------------------------------------------------------------

PROJECT_NAME=${PWD##*/}

PACKAGE=$PROJECT_NAME"_SOURCE=1 pod package  ${PROJECT_NAME}.podspec --no-mangle --exclude-deps --force  --spec-sources=http://code.xxx.com/xxx/XXXSpecRepo.git,http://xxx.xxx.com/iOS-Team/XXSpecs.git,https://github.com/CocoaPods/Specs.git"

eval $PACKAGE

ret=$?

if [ "$ret" -ne "0" ];then
	exit 1
fi

BINARY_DIR=$(ls -l | grep ^d | grep -o "${PROJECT_NAME}-.*")
mkdir $PROJECT_NAME
mkdir $PROJECT_NAME/lib
cp -a $BINARY_DIR/ios/ $PROJECT_NAME/lib

rm -rf $BINARY_DIR

echo "copy Success"
