#include "distribution.h"

void DividendDistributor::Distribute(double dDistributedAmount, double dMinimumPayout)
{
    if (mapBalance.size() == 0)
        throw runtime_error("The balance map is empty. There's not address to distribute dividends to.");

    BalanceMap mapRetainedBalance(mapBalance);
    bool bMustRedistribute = true;

    while (bMustRedistribute)
    {
        bMustRedistribute = false;

        dTotalDistributed = 0;
        vDistribution.clear();

        BalanceMap::iterator it;
        double dTotalBalance = 0;

        it = mapRetainedBalance.begin();
        while (it != mapRetainedBalance.end())
        {
            dTotalBalance += it->second;
            it++;
        }

        it = mapRetainedBalance.begin();
        while (it != mapRetainedBalance.end())
        {
            double dDistributed = it->second * dDistributedAmount / dTotalBalance;
            if (dDistributed < dMinimumPayout)
            {
                mapRetainedBalance.erase(it++);
                bMustRedistribute = true;
                continue;
            }
            Distribution distribution(it->first, it->second, dDistributed);
            vDistribution.push_back(distribution);

            dTotalDistributed += dDistributed;

            it++;
        }
    }
    if (dTotalDistributed == 0)
        throw runtime_error("No address received dividends.");

}


