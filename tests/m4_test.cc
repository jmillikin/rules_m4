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

    std::unique_ptr<Runfiles> runfiles_;
};

TEST_F(RulesM4, ExpansionTest) {
    const char EXPECT[] = R"(#line 2 "tests/expansion_test.in"
Hello, world!
)";
    const auto got = ReadFile("io_bazel_rules_m4/tests/expansion_test.txt");
    ASSERT_EQ(got, EXPECT);
}

TEST_F(RulesM4, GenruleTest) {
    const char EXPECT[] = R"(#line 2 "genrule_test.in"
Hello, world!
)";
    const auto got = ReadFile("io_bazel_rules_m4/tests/genrule_test.txt");
    ASSERT_EQ(got, EXPECT);
}

TEST_F(RulesM4, RecoveryTest) {
    const char EXPECT[] = R"(from template_1: Hello, world!
from template_2: Hello, world (again)!
)";
    const auto got = ReadFile("io_bazel_rules_m4/tests/template_test");
    ASSERT_EQ(got, EXPECT);
}
