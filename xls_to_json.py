
#!/usr/bin/env python
# -*- coding: utf-8 -*-
import argparse
import json
import os
import sys

try:
    import pandas as pd
except ImportError:
    print("Error: pandas is not installed. Please install it first:")
    print("pip install pandas xlrd openpyxl")
    sys.exit(1)


def xls_to_json(input_file, output_file=None, encoding='utf-8'):
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' does not exist.")
        return False

    try:
        all_sheets = pd.read_excel(input_file, sheet_name=None)
    except Exception as e:
        print(f"Error reading Excel file: {str(e)}")
        return False

    if not all_sheets:
        print("Warning: The Excel file has no sheets.")
        return False

    result = {}
    for sheet_name, df in all_sheets.items():
        if df.empty:
            result[sheet_name] = {}
            continue

        # 1. 先转成原来的数组格式
        records = df.to_dict('records')

        # 2. 再转成字典格式：优先用"对象名"，其次"板块名"等
        sheet_dict = {}
        for row in records:
            # 按优先级找唯一标识字段
            key = row.get("id")

            if key is not None:
                sheet_dict[str(key)] = row
            else:
                # 如果这行没有任何标识字段，回退为数组（保留原始顺序）
                # 这里把整个 sheet 回退为数组，避免混合结构
                result[sheet_name] = records
                break
        else:
            # 所有行都有标识字段，成功转为字典
            result[sheet_name] = sheet_dict

    if output_file is None:
        output_file = os.path.splitext(input_file)[0] + '.json'

    try:
        with open(output_file, 'w', encoding=encoding) as f:
            json.dump(result, f, ensure_ascii=False, indent=2)
        print(f"Successfully converted to: {output_file}")
        print(f"Processed {len(result)} sheet(s): {', '.join(result.keys())}")
        return True
    except Exception as e:
        print(f"Error writing JSON file: {str(e)}")
        return False


def main():
    parser = argparse.ArgumentParser(description='Convert XLS/XLSX files to JSON format (all sheets)')
    parser.add_argument('input', help='Path to the input XLS/XLSX file')
    parser.add_argument('-o', '--output', help='Path to the output JSON file (default: same name as input with .json extension)')
    parser.add_argument('-e', '--encoding', default='utf-8', help='Output file encoding (default: utf-8)')

    args = parser.parse_args()

    success = xls_to_json(
        input_file=args.input,
        output_file=args.output,
        encoding=args.encoding
    )

    sys.exit(0 if success else 1)


if __name__ == '__main__':
    main()
