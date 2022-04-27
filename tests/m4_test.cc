#include <fstream>
#include <iostream>

#include "gtest/gtest.h"
#include "tools/cpp/runfiles/runfiles.h"

using bazel::tools::cpp::runfiles::Runfiles;
using std::string;

class RulesM4 : public ::testing::Test {
  protected:
    void SetUp() override {
        string error;
        runfiles_.reset(Runfiles::CreateForTest(&error));
        ASSERT_EQ(error, "");
    }

    string ReadFile(const string& path) {
        string resolved_path = runfiles_->Rlocation(path);
        std::ifstream fp(resolved_path, std::ios_base::binary);
        EXPECT_TRUE(fp.is_open());
        std::stringstream buf;
        buf << fp.rdbuf();
        return buf.str();
    }

    string TestsDir() {
        const char *test_binary_ptr = getenv("TEST_BINARY");
        const char *test_workspace_ptr = getenv("TEST_WORKSPACE");

        if (test_binary_ptr == nullptr) {
            EXPECT_NE(test_binary_ptr, nullptr);
            return "";
        }
        if (test_workspace_ptr == nullptr) {
            EXPECT_NE(test_workspace_ptr, nullptr);
            return "";
        }

        string test_binary(test_binary_ptr);
        string test_workspace(test_workspace_ptr);

        size_t slash = test_binary.find_last_of('/');
        if (slash == string::npos) {
            EXPECT_NE(slash, string::npos);
            return "";
        }

        return test_workspace + "/" + test_binary.substr(0, slash);
    }

    std::unique_ptr<Runfiles> runfiles_;
};

TEST_F(RulesM4, ExpansionTest) {
    const char EXPECT[] = "#line 2 \"" EXPANSION_TEST_IN R"("
Hello, world!
)";
    const auto got = ReadFile(TestsDir() + "/expansion_test.txt");
    ASSERT_EQ(got, EXPECT);
}

TEST_F(RulesM4, GenruleTest) {
    const char EXPECT[] = R"(#line 2 "genrule_test.in"
Hello, world!
)";
    const auto got = ReadFile(TestsDir() + "/genrule_test.txt");
    ASSERT_EQ(got, EXPECT);
}

TEST_F(RulesM4, RecoveryTest) {
    const char EXPECT[] = R"(from template_1: Hello, world!
from template_2: Hello, world (again)!
)";
    const auto got = ReadFile(TestsDir() + "/template_test");
    ASSERT_EQ(got, EXPECT);
}
