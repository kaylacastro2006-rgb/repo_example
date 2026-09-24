%% 1. Load dataset
T = readtable("dirty_cafe_sales-1.csv", ...
    "VariableNamingRule","preserve");

%% 2. Handle missing and invalid values
T = standardizeMissing(T, {"ERROR","UNKNOWN",""});

% Convert numeric columns to numbers
T.("Quantity") = str2double(string(T.("Quantity")));
T.("Price Per Unit") = str2double(string(T.("Price Per Unit")));
T.("Total Spent") = str2double(string(T.("Total Spent")));

% Recalculate Total Spent when missing or incorrect
correctTotal = T.("Quantity") .* T.("Price Per Unit");

badTotal = isnan(T.("Total Spent")) | ...
           T.("Total Spent") ~= correctTotal;

T.("Total Spent")(badTotal) = correctTotal(badTotal);

%% 3. Create cleaned table
Tclean = T(~isnan(T.("Total Spent")), :);

%% 4. Summary Statistics
x = Tclean.("Total Spent");

Count = length(x)
Mean = mean(x)
StandardDeviation = std(x)
Minimum = min(x)
Median = median(x)
Maximum = max(x)
Sum = sum(x)

%% 5. Mostly Sold Item

% Remove missing items
goodItems = ~ismissing(string(Tclean.("Item")));
items = categorical(Tclean.("Item")(goodItems));

% Most transactions
itemCounts = countcats(items);
itemNames = categories(items);

[maxCount,index] = max(itemCounts);

MostFrequentItem = itemNames(index)
NumberOfTransactions = maxCount

% Greatest total quantity
quantities = Tclean.("Quantity")(goodItems);

[G,item] = findgroups(string(items));

totalQuantity = splitapply(@(x) sum(x,"omitnan"), ...
    quantities,G);

[maxQuantity,index] = max(totalQuantity);

MostQuantityItem = item(index)
TotalQuantitySold = maxQuantity

%% 6. Most Preferred Payment Method

% Remove missing payment methods
goodPayments = ~ismissing(string(Tclean.("Payment Method")));
payments = categorical(Tclean.("Payment Method")(goodPayments));

paymentCounts = countcats(payments);
paymentNames = categories(payments);

[maxPayment,index] = max(paymentCounts);

MostPreferredPayment = paymentNames(index)
NumberOfPayments = maxPayment

%% 7. Bar Chart - Total Spent per Item

[G,item] = findgroups(string(Tclean.("Item")));

revenue = splitapply(@(x) sum(x,"omitnan"), ...
    Tclean.("Total Spent"),G);

figure
bar(categorical(item),revenue)
title("Total Spent per Item")
xlabel("Item")
ylabel("Total Revenue")

%% 8. Bar Chart - Transactions per Item

figure
bar(categorical(itemNames),itemCounts)
title("Transactions per Item")
xlabel("Item")
ylabel("Number of Transactions")

%% 9. Pie Chart - Payment Methods

figure
pie(paymentCounts,paymentNames)
title("Payment Methods")

%% 10. Histogram - Total Spent

figure
histogram(Tclean.("Total Spent"))
title("Distribution of Total Spent")
xlabel("Total Spent")
ylabel("Number of Transactions")