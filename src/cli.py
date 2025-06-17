import argparse
from app import greet


def main() -> None:
    parser = argparse.ArgumentParser(description="DevOnboarder CLI")
    parser.add_argument("name", nargs="?", default="World", help="Name to greet")
    args = parser.parse_args()
    print(greet(args.name))


if __name__ == "__main__":
    main()
