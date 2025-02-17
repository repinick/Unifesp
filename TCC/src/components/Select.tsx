import React from 'react';
import Select from 'react-select';

const CustomSelect = ({ label, instanceId, options, onChange, value  }) => {
  const handleSelectChange = (selectedOption) => {
    const selectedValue = selectedOption ? selectedOption.value : '';
    onChange(selectedValue);
  };

  return (
    <div>
      <div className='flex flex-col justify-center items-center'>
        <label  className='text-white'>
            {label}
        </label>
        <div className='mb-4 mt-0.5'>
          <Select
             className='w-52 h-10 rounded-lg border border-gray-300 focus:outline-none focus:border-green-500 text-center'
             instanceId={instanceId}
             options={options}
             onChange={handleSelectChange}
             value={options.find(option => option.value === value)}
             placeholder=""
          />
        </div>
      </div>
    </div>
  );
};

export default CustomSelect;