#!/usr/bin/env python3
"""
VoiceInk 本地化工具包安装脚本
检查环境并安装必要的依赖
"""

import os
import sys
import subprocess

def check_python_version():
    """检查Python版本"""
    if sys.version_info < (3, 6):
        print("❌ Python版本太低，需要Python 3.6+")
        print(f"当前版本: {sys.version}")
        return False
    print(f"✅ Python版本检查通过: {sys.version}")
    return True

def install_dependencies():
    """安装依赖包"""
    dependencies = ['pyyaml']
    
    print("📦 检查并安装依赖包...")
    
    for package in dependencies:
        try:
            __import__(package.replace('-', '_'))
            print(f"✅ {package} 已安装")
        except ImportError:
            print(f"📥 安装 {package}...")
            try:
                subprocess.check_call([sys.executable, '-m', 'pip', 'install', package])
                print(f"✅ {package} 安装成功")
            except subprocess.CalledProcessError:
                print(f"❌ {package} 安装失败")
                return False
    
    return True

def check_project_structure():
    """检查项目结构"""
    required_dirs = ['VoiceInk', 'en.lproj', 'zh-Hans.lproj']
    required_files = ['VoiceInk.xcodeproj']
    
    print("📁 检查项目结构...")
    
    for dir_name in required_dirs:
        if not os.path.exists(dir_name):
            print(f"❌ 缺少目录: {dir_name}")
            return False
        print(f"✅ 找到目录: {dir_name}")
    
    for file_name in required_files:
        found = False
        for item in os.listdir('.'):
            if item.startswith(file_name):
                print(f"✅ 找到项目文件: {item}")
                found = True
                break
        if not found:
            print(f"❌ 缺少项目文件: {file_name}")
            return False
    
    return True

def create_directories():
    """创建必要的目录"""
    directories = [
        'localization-tools/logs',
        'localization-tools/backups'
    ]
    
    print("📂 创建必要目录...")
    
    for dir_path in directories:
        if not os.path.exists(dir_path):
            os.makedirs(dir_path)
            print(f"✅ 创建目录: {dir_path}")
        else:
            print(f"✅ 目录已存在: {dir_path}")

def make_executable():
    """设置脚本为可执行"""
    scripts = [
        'localization-tools/localize.py',
        'localization-tools/smart_localize.py',
        'localization-tools/sync_strings.py'
    ]
    
    print("🔧 设置脚本权限...")
    
    for script in scripts:
        if os.path.exists(script):
            try:
                os.chmod(script, 0o755)
                print(f"✅ 设置权限: {script}")
            except Exception as e:
                print(f"⚠️  权限设置失败 {script}: {e}")

def run_initial_check():
    """运行初始检查"""
    print("🔍 运行初始检查...")
    
    try:
        # 导入主要模块进行测试
        sys.path.append('localization-tools')
        
        # 测试配置加载
        import yaml
        with open('localization-tools/config.yaml', 'r') as f:
            config = yaml.safe_load(f)
        print("✅ 配置文件加载正常")
        
        # 测试本地化文件
        en_file = 'en.lproj/Localizable.strings'
        zh_file = 'zh-Hans.lproj/Localizable.strings'
        
        if os.path.exists(en_file):
            print("✅ 英文本地化文件存在")
        else:
            print("⚠️  英文本地化文件不存在")
        
        if os.path.exists(zh_file):
            print("✅ 中文本地化文件存在")
        else:
            print("⚠️  中文本地化文件不存在")
        
        return True
        
    except Exception as e:
        print(f"❌ 初始检查失败: {e}")
        return False

def main():
    """主安装流程"""
    print("🚀 VoiceInk 本地化工具包安装程序")
    print("=" * 50)
    
    # 检查Python版本
    if not check_python_version():
        return 1
    
    # 检查项目结构
    if not check_project_structure():
        print("❌ 请在VoiceInk项目根目录中运行此脚本")
        return 1
    
    # 安装依赖
    if not install_dependencies():
        print("❌ 依赖安装失败")
        return 1
    
    # 创建目录
    create_directories()
    
    # 设置权限
    make_executable()
    
    # 运行初始检查
    if not run_initial_check():
        print("❌ 初始检查失败")
        return 1
    
    print("\n🎉 安装完成！")
    print("\n📖 使用方法:")
    print("   python localization-tools/localize.py status    # 查看状态")
    print("   python localization-tools/localize.py full      # 执行完整流程")
    print("   python localization-tools/localize.py --help    # 查看帮助")
    
    print("\n📚 详细文档:")
    print("   localization-tools/README.md")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
