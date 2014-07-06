#include <boost/test/unit_test.hpp>

#include "main.h"
#include "script.h"

using namespace std;

typedef vector<unsigned char> valtype;
CBigNum CastToBigNum(const valtype& vch);
bool CastToBool(const valtype& vch);


BOOST_AUTO_TEST_SUITE(cold_minting_tests)

BOOST_AUTO_TEST_CASE(op_coinstake)
{
    CTransaction txCoinStake;
    txCoinStake.vin.push_back(CTxIn(uint256(123), 0));
    txCoinStake.vout.push_back(CTxOut(0, CScript()));
    txCoinStake.vout.push_back(CTxOut());
    BOOST_CHECK(txCoinStake.IsCoinStake());

    CTransaction txNonCoinStake;
    BOOST_CHECK(!txNonCoinStake.IsCoinStake());

    vector<vector<unsigned char> > stack;

    CScript script;
    script << OP_COINSTAKE;

    BOOST_CHECK(EvalScript(stack, script, txCoinStake, 0, 0, 0));
    BOOST_CHECK(stack.size() == 1);
    BOOST_CHECK(CastToBigNum(stack[0]) == 1);

    stack.clear();

    BOOST_CHECK(EvalScript(stack, script, txNonCoinStake, 0, 0, 0));
    BOOST_CHECK(stack.size() == 1);
    BOOST_CHECK(CastToBigNum(stack[0]) == 0);
}

BOOST_AUTO_TEST_SUITE_END()

