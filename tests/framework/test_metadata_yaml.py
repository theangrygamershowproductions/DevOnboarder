"""Tests for YAML Serialization Module"""

import pytest
import tempfile
from pathlib import Path
from unittest.mock import patch

from src.framework.metadata_yaml import ExtendedMetadataYAMLManager
from src.framework.extended_metadata import create_default_metadata


class TestExtendedMetadataYAMLManager:
    """Test YAML serialization and deserialization"""

    def setup_method(self):
        """Setup for each test method"""
        self.temp_dir = Path(tempfile.mkdtemp())
        self.temp_dir.mkdir(exist_ok=True)
        self.manager = ExtendedMetadataYAMLManager()

    def teardown_method(self):
        """Cleanup after each test"""
        import shutil

        if self.temp_dir.exists():
            shutil.rmtree(self.temp_dir)

    def test_serialize_metadata(self):
        """Test basic metadata serialization"""
        metadata = create_default_metadata("test_script.sh", "ci_cd")
        yaml_str = self.manager.serialize_metadata(metadata)
        assert isinstance(yaml_str, str)
        assert "script_name: test_script.sh" in yaml_str

    def test_deserialize_metadata_yaml_error(self):
        """Test deserialize_metadata exception handling - lines 132"""
        with pytest.raises(ValueError) as exc_info:
            self.manager.deserialize_metadata("Invalid YAML: [unclosed")
        assert "Invalid YAML content" in str(exc_info.value)

    def test_deserialize_metadata_non_dict(self):
        """Test deserialize_metadata with non-dict YAML - lines 138-140"""
        with pytest.raises(ValueError) as exc_info:
            self.manager.deserialize_metadata("- item1\n- item2")
        assert "not a dictionary" in str(exc_info.value)

    def test_save_metadata_exception(self):
        """Test save_metadata exception handling - lines 181-183"""
        metadata = create_default_metadata("test.sh", "testing")
        test_file_path = Path(self.temp_dir / "test.sh")

        with patch.object(
            self.manager,
            "serialize_metadata",
            side_effect=Exception("Serialization failed"),
        ):
            with pytest.raises(Exception) as exc_info:
                self.manager.save_metadata(test_file_path, metadata)
            assert "Serialization failed" in str(exc_info.value)

    def test_create_default_metadata_file_exception(self):
        """Test create_default_metadata_file exception handling - lines 210-212"""
        with patch.object(
            self.manager, "save_metadata", side_effect=Exception("Save failed")
        ):
            with pytest.raises(Exception) as exc_info:
                self.manager.create_default_metadata_file(Path("/invalid/path"))
            assert "Save failed" in str(exc_info.value)

    def test_generate_metadata_report_exception_handling(self):
        """Test generate_metadata_report with mixed valid/invalid files.

        Tests lines 341-342 in metadata_yaml.py
        """
        # Create a valid metadata file
        valid_metadata = create_default_metadata("valid.sh", "testing")
        valid_script = self.temp_dir / "valid.sh"
        valid_script.touch()  # Create the script file
        self.manager.save_metadata(valid_script, valid_metadata)

        # Create a file that will cause issues during processing
        problematic_file = self.temp_dir / ".metadata" / "problematic.sh.yaml"
        problematic_file.parent.mkdir(exist_ok=True)
        with open(problematic_file, "w") as f:
            f.write("invalid: yaml: content: [")

        # Generate report (should handle exceptions gracefully)
        report = self.manager.generate_metadata_report(self.temp_dir)

        # Should still generate a report even with some invalid files
        assert "total_metadata_files" in report
        assert report["total_metadata_files"] >= 1
        assert "validation_results" in report

    def test_serialization_exception_handling(self):
        """Test serialization with mocked exception to cover lines 112-114."""
        metadata = create_default_metadata("test.sh", "ci_cd")

        with patch("yaml.dump", side_effect=Exception("YAML dump failed")):
            with pytest.raises(Exception) as exc_info:
                self.manager.serialize_metadata(metadata)
            assert "YAML dump failed" in str(exc_info.value)

    def test_deserialization_validation_error(self):
        """Test deserialization with validation error to cover lines 198-212."""
        # Create invalid YAML that will pass YAML parsing but fail validation
        invalid_yaml = """
        script_name: test.sh
        category: invalid_category  # This should cause validation error
        governance:
          level: invalid_level  # This should also cause validation error
        """

        with pytest.raises(Exception):
            self.manager.deserialize_metadata(invalid_yaml)

    def test_load_metadata_file_not_found(self):
        """Test loading non-existent metadata file to cover line 242."""
        non_existent_path = Path("/non/existent/script.sh")
        result = self.manager.load_metadata(non_existent_path)
        assert result is None

    def test_save_metadata_directory_creation_error(self):
        """Test metadata saving with directory creation error to cover line 265."""
        metadata = create_default_metadata("test.sh", "ci_cd")

        # Try to save to a path where directory creation will fail
        invalid_path = Path("/proc/1/test.sh")  # System directory

        with pytest.raises(Exception):
            self.manager.save_metadata(invalid_path, metadata)

    def test_create_default_metadata_exception_handling(self):
        """Test default metadata creation with exception to cover lines 341-342."""
        with patch(
            "src.framework.metadata_yaml.create_default_metadata",
            side_effect=Exception("Creation failed"),
        ):
            with pytest.raises(Exception):
                self.manager.create_default_metadata_file(Path("test.sh"))

    def test_metadata_validation_error_paths(self):
        """Test metadata validation error handling to cover lines 367-368."""
        # Create metadata with missing required fields
        incomplete_yaml = """
        script_name: test.sh
        # Missing category field
        """

        with pytest.raises(Exception):
            self.manager.deserialize_metadata(incomplete_yaml)

    def test_report_generation_file_processing_error(self):
        """Test report generation with file processing errors to cover lines 381-382."""
        # Create a metadata file with permission issues
        restricted_file = self.temp_dir / ".metadata" / "restricted.sh.yaml"
        restricted_file.parent.mkdir(exist_ok=True)
        restricted_file.write_text("script_name: test.sh")

        # Mock file reading to simulate permission error
        with patch(
            "pathlib.Path.read_text", side_effect=PermissionError("Access denied")
        ):
            report = self.manager.generate_metadata_report(self.temp_dir)
            # Should handle the error gracefully and continue
            assert "total_metadata_files" in report

    def test_yaml_loading_exception_handling(self):
        """Test YAML loading with exception to cover lines 398-399."""
        # Test the _load_and_validate_yaml method with invalid content
        with patch("yaml.safe_load", side_effect=Exception("YAML load failed")):
            with pytest.raises(Exception):
                self.manager.deserialize_metadata("valid: yaml")

    def test_load_metadata_exception_handling(self):
        """Test load_metadata with exception to cover lines 204-212."""
        # Create a valid metadata file
        test_script = self.temp_dir / "test.sh"
        test_script.write_text("#!/bin/bash\necho test")

        metadata = create_default_metadata("test.sh", "ci_cd")
        self.manager.save_metadata(test_script, metadata)

        # Mock read_text to cause an exception
        with patch("pathlib.Path.read_text", side_effect=Exception("Read failed")):
            with pytest.raises(Exception):
                self.manager.load_metadata(test_script)

    def test_is_valid_metadata_file_false_case(self):
        """Test is_valid_metadata_file returns False to cover line 242."""
        # Create an invalid metadata file
        test_script = self.temp_dir / "invalid.sh"
        test_script.write_text("#!/bin/bash\necho test")

        # Create metadata file with invalid content
        metadata_dir = self.temp_dir / ".metadata"
        metadata_dir.mkdir(exist_ok=True)
        metadata_file = metadata_dir / "invalid.sh.yaml"
        metadata_file.write_text("invalid: yaml: content: [")

        result = self.manager.validate_metadata_file(metadata_file)
        assert result is False

    def test_save_metadata_with_directory_creation(self):
        """Test save_metadata creates directory successfully to cover line 265."""
        # Create a script in a new subdirectory that doesn't exist yet
        new_subdir = self.temp_dir / "new_subdir"
        test_script = new_subdir / "test.sh"

        metadata = create_default_metadata("test.sh", "ci_cd")

        # This should create the .metadata directory
        self.manager.save_metadata(test_script, metadata)

        # Verify the metadata file was created
        metadata_file = new_subdir / ".metadata" / "test.sh.yaml"
        assert metadata_file.exists()

    def test_create_default_metadata_file_success(self):
        """Test successful default metadata file creation to cover lines 341-342."""
        test_script = self.temp_dir / "new_script.sh"
        test_script.write_text("#!/bin/bash\necho test")

        # This should successfully create the default metadata file
        self.manager.create_default_metadata_file(test_script)

        # Verify the metadata file was created
        metadata_file = self.temp_dir / ".metadata" / "new_script.sh.yaml"
        assert metadata_file.exists()

    def test_metadata_validation_success_path(self):
        """Test metadata validation success to cover lines 367-368."""
        # Use create_default_metadata to get a valid structure
        metadata = create_default_metadata("test.sh", "testing")

        # Serialize it to YAML first
        valid_yaml = self.manager.serialize_metadata(metadata)

        # Then deserialize it - this should successfully parse without exceptions
        result = self.manager.deserialize_metadata(valid_yaml)
        assert result is not None
        assert result.script_name == "test.sh"

    def test_report_generation_successful_processing(self):
        """Test successful report generation to cover lines 381-382."""
        # Create valid metadata files
        test_script = self.temp_dir / "test.sh"
        test_script.write_text("#!/bin/bash\necho test")

        metadata = create_default_metadata("test.sh", "ci_cd")
        self.manager.save_metadata(test_script, metadata)

        # Generate report (should process files successfully)
        report = self.manager.generate_metadata_report(self.temp_dir)

        assert "total_metadata_files" in report
        assert report["total_metadata_files"] >= 1
        assert "validation_results" in report

    def test_yaml_loading_successful_path(self):
        """Test successful YAML loading to cover lines 398-399."""
        # Use create_default_metadata to get a valid structure
        metadata = create_default_metadata("test.sh", "testing")

        # Serialize it to YAML first
        valid_yaml = self.manager.serialize_metadata(metadata)

        # This should successfully load and validate
        result = self.manager.deserialize_metadata(valid_yaml)
        assert result is not None
