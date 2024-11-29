import os
import sys

from cocotb.runner import get_runner
import yaml


def read_yaml(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)


def get_all_dependencies(yaml_file_path, module_name):
    def add_dependencies(dependency_info, module_name, existing):
        existing.add(module_name)
        dependencies = dependency_info.get(module_name)
        for d in dependencies:
            add_dependencies(dependency_info, d, existing)

    dependency_info = read_yaml(yaml_file_path)
    dependencies = set()
    add_dependencies(dependency_info, module_name, dependencies)
    return dependencies


def run():
    project_path = sys.argv[1]
    module_name = sys.argv[2]

    dep_file_path = os.path.join(project_path, "tests", "dependencies.yaml")
    src_path = os.path.join(project_path, "src")

    dependencies = get_all_dependencies(dep_file_path, module_name)

    sources = [os.path.join(src_path, dep + ".v") for dep in dependencies]

    runner = get_runner("icarus")
    runner.build(
        sources=sources,
        hdl_toplevel=module_name,
        clean=True
    )

    runner.test(hdl_toplevel=module_name,
                test_module=f"test_{module_name}")


if __name__ == '__main__':
    run()
