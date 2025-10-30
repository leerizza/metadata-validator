#!/usr/bin/env python3
import re
import sys
import yaml
from pathlib import Path

class SQLValidator:
    def __init__(self, rules_file='.github/sql-validation-rules.yml'):
        with open(rules_file) as f:
            self.rules = yaml.safe_load(f)
    
    def validate_file(self, sql_file, operation_type='create'):
        """Validate a single SQL file"""
        content = Path(sql_file).read_text()
        violations = []
        
        rules = self.rules['type_guards'].get(operation_type, {})
        if not rules.get('enabled', False):
            return []
        
        for rule in rules.get('disallowed_patterns', []):
            pattern = rule['pattern']
            if re.search(pattern, content, re.IGNORECASE):
                violations.append({
                    'file': sql_file,
                    'rule': rule['name'],
                    'message': rule['message'],
                    'severity': rule.get('severity', 'error'),
                    'examples': rule.get('examples', {})
                })
        
        return violations
    
    def validate_files(self, files, operation_type='create'):
        """Validate multiple files"""
        all_violations = []
        for file in files:
            violations = self.validate_file(file, operation_type)
            all_violations.extend(violations)
        return all_violations
    
    def print_report(self, violations):
        """Print validation report"""
        if not violations:
            print("✅ All validations passed!")
            return 0
        
        print("\n" + "="*50)
        print("TYPE GUARD FAILED!")
        print("="*50 + "\n")
        
        errors = [v for v in violations if v['severity'] == 'error']
        warnings = [v for v in violations if v['severity'] == 'warning']
        
        if errors:
            print(f"❌ {len(errors)} error(s) found:\n")
            for v in errors:
                print(f"  File: {v['file']}")
                print(f"  Rule: {v['rule']}")
                print(f"  Message: {v['message']}")
                if v.get('examples'):
                    print(f"    [BAD]  {v['examples'].get('bad', '')}")
                    print(f"    [GOOD] {v['examples'].get('good', '')}")
                print()
        
        if warnings:
            print(f"⚠️  {len(warnings)} warning(s) found:\n")
            for v in warnings:
                print(f"  File: {v['file']}")
                print(f"  Message: {v['message']}")
                print()
        
        return 1 if errors else 0

if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Validate SQL files')
    parser.add_argument('files', nargs='+', help='SQL files to validate')
    parser.add_argument('--type', choices=['create', 'alter', 'drop'], 
                        default='create', help='Operation type')
    parser.add_argument('--rules', default='.github/sql-validation-rules.yml',
                        help='Rules file path')
    
    args = parser.parse_args()
    
    validator = SQLValidator(args.rules)
    violations = validator.validate_files(args.files, args.type)
    exit_code = validator.print_report(violations)
    sys.exit(exit_code)